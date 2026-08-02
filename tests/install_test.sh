#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_dir="$(mktemp -d)"
cleanup() { rm -rf -- "${temp_dir}"; }
trap cleanup EXIT HUP INT TERM

fixtures="${temp_dir}/fixtures"
mock_bin="${temp_dir}/bin"
url_log="${temp_dir}/urls"
mkdir -p "${fixtures}" "${mock_bin}"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

make_fixture() {
  local platform="$1"
  local asset="mlir-lsp-${platform}.tar.gz"
  local package_dir="${temp_dir}/package/mlir-lsp-${platform}"

  mkdir -p "${package_dir}"
  printf '#!/usr/bin/env sh\nprintf "%s fixture\\n"\n' "${platform}" \
    > "${package_dir}/mlir-lsp"
  chmod 0755 "${package_dir}/mlir-lsp"
  cp "${repo_root}/README.md" "${repo_root}/LICENSE" "${package_dir}/"
  tar -C "${temp_dir}/package" -czf "${fixtures}/${asset}" "mlir-lsp-${platform}"
  (cd "${fixtures}" && sha256sum "${asset}" > "${asset}.sha256")
}

make_fixture linux-x86_64
make_fixture macos-arm64

cat > "${mock_bin}/uname" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  -s) printf '%s\n' "${TEST_UNAME_S}" ;;
  -m) printf '%s\n' "${TEST_UNAME_M}" ;;
  *) exit 2 ;;
esac
EOF

cat > "${mock_bin}/curl" <<'EOF'
#!/usr/bin/env bash
output=''
url=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) output="$2"; shift 2 ;;
    --fail | --location | --show-error | --silent) shift ;;
    --retry) shift 2 ;;
    *) url="$1"; shift ;;
  esac
done
printf '%s\n' "${url}" >> "${TEST_URL_LOG}"
cp "${TEST_FIXTURES}/${url##*/}" "${output}"
EOF

cat > "${mock_bin}/shasum" <<'EOF'
#!/usr/bin/env bash
[[ "$1" == '-a' && "$2" == '256' ]] || exit 2
shift 2
sha256sum "$@"
EOF
chmod 0755 "${mock_bin}/uname" "${mock_bin}/curl" "${mock_bin}/shasum"

run_installer() {
  TEST_UNAME_S="$1" TEST_UNAME_M="$2" TEST_FIXTURES="${fixtures}" \
    TEST_URL_LOG="${url_log}" INSTALL_PREFIX="$3" PATH="${mock_bin}:${PATH}" \
    "${repo_root}/install.sh"
}

install_dir="${temp_dir}/install"
mkdir -p "${install_dir}"
printf 'old binary\n' > "${install_dir}/mlir-lsp"
printf '' > "${url_log}"
env -u MLIR_LSP_VERSION TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 \
  TEST_FIXTURES="${fixtures}" TEST_URL_LOG="${url_log}" INSTALL_PREFIX="${install_dir}" \
  PATH="${mock_bin}:${PATH}" "${repo_root}/install.sh"
[[ -x "${install_dir}/mlir-lsp" ]] || fail 'installed binary is not executable'
[[ "$("${install_dir}/mlir-lsp")" == 'linux-x86_64 fixture' ]] || fail 'old binary was not replaced'
[[ "$(< "${url_log}")" == *'/releases/latest/download/mlir-lsp-linux-x86_64.tar.gz'* ]] || \
  fail 'latest release URL was not used'

printf '' > "${url_log}"
MLIR_LSP_VERSION=nightly run_installer Linux x86_64 "${install_dir}"
[[ "$(< "${url_log}")" == *'/releases/download/nightly/mlir-lsp-linux-x86_64.tar.gz'* ]] || \
  fail 'nightly release URL was not used'

printf '' > "${url_log}"
MLIR_LSP_VERSION=v0.1.0 run_installer Darwin arm64 "${install_dir}"
[[ "$("${install_dir}/mlir-lsp")" == 'macos-arm64 fixture' ]] || fail 'macOS asset was not installed'
[[ "$(< "${url_log}")" == *'/releases/download/v0.1.0/mlir-lsp-macos-arm64.tar.gz'* ]] || \
  fail 'pinned release URL was not used'

if run_installer Darwin x86_64 "${install_dir}" 2> "${temp_dir}/unsupported-error"; then
  fail 'unsupported platform succeeded'
fi
[[ "$(< "${temp_dir}/unsupported-error")" == *'Supported platforms:'* ]] || \
  fail 'unsupported platform message omitted supported combinations'

printf '%064d  mlir-lsp-linux-x86_64.tar.gz\n' 0 \
  > "${fixtures}/mlir-lsp-linux-x86_64.tar.gz.sha256"
if MLIR_LSP_VERSION=latest run_installer Linux x86_64 "${install_dir}" \
  2> "${temp_dir}/checksum-error"; then
  fail 'invalid checksum succeeded'
fi
[[ "$(< "${temp_dir}/checksum-error")" == *'SHA-256 verification failed'* ]] || \
  fail 'checksum failure was not explained'

printf 'Installer tests passed.\n'
