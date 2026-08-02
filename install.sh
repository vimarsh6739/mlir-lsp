#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bazel_command="${BAZEL:-bazel}"
install_dir="${HOME}/.local/bin"

cd "${workspace_dir}"
"${bazel_command}" build --config=public_cache //:copy-enzymexla-lsp-server
mkdir -p "${install_dir}"
install -m 755 \
  "${workspace_dir}/bazel-bin/enzymexla-lsp-server" \
  "${install_dir}/enzymexla-lsp-server"
