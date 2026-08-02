#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bazel_command="${BAZEL:-bazel}"
install_dir="${HOME}/.local/bin"

cd "${workspace_dir}"
"${bazel_command}" build --config=public_cache \
  //:copy-enzymexla-lsp-server \
  //:write-enzymexla-source-mode
source_mode="$(<"${workspace_dir}/bazel-bin/enzymexla-source-mode")"

mkdir -p "${install_dir}"
install -m 755 \
  "${workspace_dir}/bazel-bin/enzymexla-lsp-server" \
  "${install_dir}/enzymexla-lsp-server"

case "${source_mode}" in
  archive)
    echo "Keeping the standalone Bazel output for the pinned Enzyme-JAX archive."
    # Temporarily retain build artifacts while validating installs across platforms.
    # "${bazel_command}" clean --expunge
    ;;
  override)
    echo "Keeping the standalone Bazel output for the local Enzyme-JAX override."
    ;;
  *)
    echo "Unknown Enzyme-JAX source mode: ${source_mode}" >&2
    exit 1
    ;;
esac
