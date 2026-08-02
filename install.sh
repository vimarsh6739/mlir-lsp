#!/usr/bin/env bash
set -euo pipefail

command -v bazel >/dev/null 2>&1 || exit 1
command -v mlir-lsp-server >/dev/null 2>&1 && exit 0

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install_prefix="${INSTALL_PREFIX:-${HOME}/.local/bin}"

cd "${workspace_dir}"
bazel build //:mlir-lsp-server

mkdir -p "${install_prefix}"
install -m 755 \
  "${workspace_dir}/bazel-bin/mlir-lsp-server" \
  "${install_prefix}/mlir-lsp-server"
