#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) platform="linux-x86_64" ;;
  Darwin:arm64) platform="macos-arm64" ;;
  *)
    printf 'Unsupported platform: %s %s\n' "$(uname -s)" "$(uname -m)" >&2
    printf 'Supported platforms: Linux x86-64 and macOS Apple Silicon.\n' >&2
    exit 1
    ;;
esac

version="${MLIR_LSP_VERSION:-latest}"
case "${version}" in
  latest) release_path="latest/download" ;;
  *[!A-Za-z0-9._-]*)
    printf 'Invalid MLIR_LSP_VERSION: %s\n' "${version}" >&2
    exit 1
    ;;
  *) release_path="download/${version}" ;;
esac

if [[ -n "${INSTALL_PREFIX:-}" ]]; then
  install_prefix="${INSTALL_PREFIX}"
elif [[ -n "${HOME:-}" ]]; then
  install_prefix="${HOME}/.local/bin"
else
  printf 'HOME is unset; set INSTALL_PREFIX to the destination directory.\n' >&2
  exit 1
fi

for command_name in curl tar mktemp; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "${command_name}" >&2
    exit 1
  fi
done

asset="mlir-lsp-${platform}.tar.gz"
base_url="https://github.com/vimarsh6739/mlir-lsp/releases/${release_path}"
temp_dir="$(mktemp -d)"
staged_binary=""
cleanup() {
  rm -rf -- "${temp_dir}"
  [[ -z "${staged_binary}" ]] || rm -f -- "${staged_binary}"
}
trap cleanup EXIT HUP INT TERM

curl --fail --location --retry 3 --show-error --silent \
  --output "${temp_dir}/${asset}" "${base_url}/${asset}"
curl --fail --location --retry 3 --show-error --silent \
  --output "${temp_dir}/${asset}.sha256" "${base_url}/${asset}.sha256"

read -r expected_checksum _ < "${temp_dir}/${asset}.sha256"
case "${platform}" in
  linux-*)
    command -v sha256sum >/dev/null 2>&1 || {
      printf 'Required command not found: sha256sum\n' >&2
      exit 1
    }
    actual_checksum="$(sha256sum "${temp_dir}/${asset}")"
    ;;
  macos-*)
    command -v shasum >/dev/null 2>&1 || {
      printf 'Required command not found: shasum\n' >&2
      exit 1
    }
    actual_checksum="$(shasum -a 256 "${temp_dir}/${asset}")"
    ;;
esac
actual_checksum="${actual_checksum%% *}"

if [[ "${actual_checksum}" != "${expected_checksum}" ]]; then
  printf 'SHA-256 verification failed for %s\n' "${asset}" >&2
  exit 1
fi

mkdir -p "${temp_dir}/extract" "${install_prefix}"
tar -xzf "${temp_dir}/${asset}" -C "${temp_dir}/extract"
binary="${temp_dir}/extract/mlir-lsp-${platform}/mlir-lsp"
if [[ ! -f "${binary}" ]]; then
  printf 'Archive does not contain mlir-lsp at the expected path.\n' >&2
  exit 1
fi

staged_binary="${install_prefix}/.mlir-lsp.$$"
cp "${binary}" "${staged_binary}"
chmod 0755 "${staged_binary}"
mv -f "${staged_binary}" "${install_prefix}/mlir-lsp"
staged_binary=""
printf 'Installed mlir-lsp to %s\n' "${install_prefix}/mlir-lsp"

case ":${PATH:-}:" in
  *":${install_prefix}:"*) ;;
  *) printf 'Warning: %s is not on PATH.\n' "${install_prefix}" >&2 ;;
esac
