#!/usr/bin/env bash
set -euo pipefail

command -v bazel >/dev/null 2>&1 || exit 1
command -v mlir-lsp-server >/dev/null 2>&1 && exit 0

install_prefix="${INSTALL_PREFIX:-${HOME}/.local/bin}"

bazel build //:mlir-lsp-server

mkdir -p "${install_prefix}"
install -m 755 \
  bazel-bin/mlir-lsp-server \
  "${install_prefix}/mlir-lsp-server"
