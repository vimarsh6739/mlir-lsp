#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  printf 'Usage: %s <platform> <binary> <source-commit> <output-dir>\n' "$0" >&2
  exit 2
fi

platform="$1"
binary="$2"
source_commit="$3"
output_dir="$4"

case "${platform}" in
  linux-x86_64 | macos-arm64) ;;
  *)
    printf 'Unsupported release platform: %s\n' "${platform}" >&2
    exit 1
    ;;
esac

if [[ ! -x "${binary}" ]]; then
  printf 'Release binary is missing or not executable: %s\n' "${binary}" >&2
  exit 1
fi

package="mlir-lsp-${platform}"
archive="${package}.tar.gz"
temp_dir="$(mktemp -d)"
cleanup() { rm -rf -- "${temp_dir}"; }
trap cleanup EXIT HUP INT TERM

mkdir -p "${temp_dir}/${package}" "${output_dir}"
cp "${binary}" "${temp_dir}/${package}/mlir-lsp"
chmod 0755 "${temp_dir}/${package}/mlir-lsp"
cp README.md LICENSE "${temp_dir}/${package}/"
printf '%s\n' "${source_commit}" > "${temp_dir}/${package}/SOURCE_COMMIT"

tar -C "${temp_dir}" -czf "${output_dir}/${archive}" "${package}"
(
  cd "${output_dir}"
  case "${platform}" in
    linux-*) sha256sum "${archive}" > "${archive}.sha256" ;;
    macos-*) shasum -a 256 "${archive}" > "${archive}.sha256" ;;
  esac
)
