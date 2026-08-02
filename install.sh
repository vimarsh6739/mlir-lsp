#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bazel_command="${BAZEL:-bazel}"
install_dir="${INSTALL_DIR:-${HOME}/.local/bin}"
installed_server="${install_dir}/mlir-lsp-server"
legacy_server="${install_dir}/enzymexla-lsp-server"
force_install=false

case "${1:-}" in
  "") ;;
  --force) force_install=true ;;
  *)
    echo "Usage: $0 [--force]" >&2
    exit 2
    ;;
esac

if (( $# > 1 )); then
  echo "Usage: $0 [--force]" >&2
  exit 2
fi

if [[ "${force_install}" == false ]]; then
  if [[ -x "${installed_server}" ]]; then
    echo "Using existing ${installed_server}"
    exit 0
  fi

  if [[ -x "${legacy_server}" ]]; then
    mkdir -p "${install_dir}"
    install -m 755 "${legacy_server}" "${installed_server}"
    echo "Reused ${legacy_server} as ${installed_server}"
    exit 0
  fi
fi

cd "${workspace_dir}"
"${bazel_command}" build --config=public_cache //:mlir-lsp-server

mkdir -p "${install_dir}"
install -m 755 \
  "${workspace_dir}/bazel-bin/mlir-lsp-server" \
  "${installed_server}"

echo "Installed ${installed_server}"
