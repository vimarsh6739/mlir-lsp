#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bazel_command="${BAZEL:-bazel}"
install_dir="${INSTALL_DIR:-${HOME}/.local/bin}"

cd "${workspace_dir}"

shutdown_bazel() {
  "${bazel_command}" shutdown || true
}
trap shutdown_bazel EXIT

"${bazel_command}" build --config=public_cache //:mlir-lsp-server

mkdir -p "${install_dir}"
install -m 755 \
  "${workspace_dir}/bazel-bin/mlir-lsp-server" \
  "${install_dir}/mlir-lsp-server"

echo "Installed ${install_dir}/mlir-lsp-server"
