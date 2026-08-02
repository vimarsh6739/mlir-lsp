workspace(name = "mlir_lsp")

# Load Enzyme-JAX, configure LLVM.
load("//third_party/enzyme_ad:workspace.bzl", enzyme_jax_workspace = "repo")

enzyme_jax_workspace()

NEW_XLA_PATCHES = []

LLVM_TARGETS = [
    "AArch64",
    "AMDGPU",
    "NVPTX",
    "X86",
]

load("@enzyme_ad//third_party/jax:workspace.bzl", jax_workspace = "repo")
load("@enzyme_ad//third_party/ml_toolchain:workspace.bzl", ml_toolchain_workspace = "repo")

jax_workspace([])

load("@enzyme_ad//third_party/xla:workspace.bzl", xla_workspace = "repo")

xla_workspace(NEW_XLA_PATCHES)

load("@enzyme_ad//third_party/cuda_tile:workspace.bzl", cuda_tile_workspace = "repo")
load("@enzyme_ad//third_party/enzyme:workspace.bzl", enzyme_workspace = "repo")

enzyme_workspace()

cuda_tile_workspace("@enzyme_ad")

load("@jax//third_party/xla:workspace.bzl", jax_xla_workspace = "repo")

jax_xla_workspace()

load("@xla//:workspace4.bzl", "xla_workspace4")

xla_workspace4()

load("@xla//:workspace3.bzl", "xla_workspace3")

xla_workspace3()

ml_toolchain_workspace()

load("@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl", "cc_toolchain_deps")

cc_toolchain_deps()

load("@xla//third_party/py:python_init_rules.bzl", "python_init_rules")

python_init_rules()

load("@xla//third_party/py:python_init_repositories.bzl", "python_init_repositories")

python_init_repositories(
    local_wheel_inclusion_list = [
        "enzyme_ad*",
    ],
    requirements = {
        "3.11": "@enzyme_ad//builddeps:requirements_lock_3_11.txt",
        "3.12": "@enzyme_ad//builddeps:requirements_lock_3_12.txt",
        "3.13": "@enzyme_ad//builddeps:requirements_lock_3_13.txt",
    },
)

load("@xla//third_party/py:python_init_toolchains.bzl", "python_init_toolchains")

python_init_toolchains()

load("@xla//third_party/py:python_init_pip.bzl", "python_init_pip")

python_init_pip()

load("@pypi//:requirements.bzl", "install_deps")

install_deps()

load("@xla//:workspace2.bzl", "xla_workspace2")

xla_workspace2()

load("@xla//third_party/llvm:workspace.bzl", llvm = "repo")

llvm("llvm-raw")

load("@llvm-raw//utils/bazel:configure.bzl", "llvm_configure")

llvm_configure(
    name = "llvm-project",
    targets = LLVM_TARGETS,
)

load("@xla//:workspace1.bzl", "xla_workspace1")

xla_workspace1()

load("@xla//:workspace0.bzl", "xla_workspace0")

xla_workspace0()

load("@jax//third_party/flatbuffers:workspace.bzl", flatbuffers = "repo")

flatbuffers()

load("@jax//third_party/external_deps:workspace.bzl", "external_deps_repository")

external_deps_repository(name = "rocm_external_test_deps")

load("@jax//:test_shard_count.bzl", "test_shard_count_repository")

test_shard_count_repository(
    name = "test_shard_count",
)

load("@jax//jaxlib:jax_python_wheel.bzl", "jax_python_wheel_repository")

jax_python_wheel_repository(
    name = "jax_wheel",
    version_key = "_version",
    version_source = "@jax//jax:version.py",
)

load("@jax//third_party/rocm_wheels:workspace.bzl", "rocm_wheels_repository")
load("@jax_wheel//:wheel.bzl", "WHEEL_VERSION")
load("@python_version_repo//:py_version.bzl", "HERMETIC_PYTHON_VERSION")

# Pre-built ROCm wheels from a GitHub release (ROCm/rocm-jax).
rocm_wheels_repository(
    name = "rocm_wheels",
    jaxlib_version = WHEEL_VERSION,
    python_version = HERMETIC_PYTHON_VERSION,
    # rocm_version = "7.2.0",  # Optional: pick a specific ROCm version.
)

# Used for --//jax:build_jaxlib=false (pre-built wheels from GitHub).
external_deps_repository(
    name = "rocm_prebuilt_test_deps",
    deps = [
        "@rocm_wheels//:rocm_pjrt_py_import",
        "@rocm_wheels//:rocm_plugin_py_import",
    ],
)

jax_python_wheel_repository(
    name = "jax_wheel",
    version_key = "_version",
    version_source = "@jax//jax:version.py",
)

load(
    "@xla//third_party/py:python_wheel.bzl",
    "nvidia_wheel_versions_repository",
    "python_wheel_version_suffix_repository",
)

nvidia_wheel_versions_repository(
    name = "nvidia_wheel_versions",
    versions_source = "@jax//build:nvidia-requirements.txt",
)

python_wheel_version_suffix_repository(
    name = "jax_wheel_version_suffix",
)

load(
    "@rules_ml_toolchain//gpu/cuda:cuda_json_init_repository.bzl",
    "cuda_json_init_repository",
)

cuda_json_init_repository()

load(
    "@cuda_redist_json//:distributions.bzl",
    "CUDA_REDISTRIBUTIONS",
    "CUDNN_REDISTRIBUTIONS",
)
load(
    "@rules_ml_toolchain//gpu/cuda:cuda_redist_init_repositories.bzl",
    "cuda_redist_init_repositories",
    "cudnn_redist_init_repository",
)
load(
    "@rules_ml_toolchain//gpu/cuda:cuda_redist_versions.bzl",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)
load("@xla//third_party/cccl:workspace.bzl", "CCCL_3_2_0_DIST_DICT", "CCCL_GITHUB_VERSIONS_TO_BUILD_TEMPLATES")

cuda_redist_init_repositories(
    cuda_redistributions = CUDA_REDISTRIBUTIONS | CCCL_3_2_0_DIST_DICT,
    redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES | CCCL_GITHUB_VERSIONS_TO_BUILD_TEMPLATES,
)

cudnn_redist_init_repository(
    cudnn_redistributions = CUDNN_REDISTRIBUTIONS,
)

load(
    "@rules_ml_toolchain//gpu/cuda:cuda_configure.bzl",
    "cuda_configure",
)

cuda_configure(name = "local_config_cuda")

load(
    "@rules_ml_toolchain//gpu/nccl:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository",
)

nccl_redist_init_repository()

load(
    "@rules_ml_toolchain//gpu/nccl:nccl_configure.bzl",
    "nccl_configure",
)

nccl_configure(name = "local_config_nccl")

load(
    "@rules_ml_toolchain//gpu/nvshmem:nvshmem_json_init_repository.bzl",
    "nvshmem_json_init_repository",
)

nvshmem_json_init_repository()

load(
    "@nvshmem_redist_json//:distributions.bzl",
    "NVSHMEM_REDISTRIBUTIONS",
)
load(
    "@rules_ml_toolchain//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

nvshmem_redist_init_repository(
    nvshmem_redistributions = NVSHMEM_REDISTRIBUTIONS,
)

# Reuse the Hedron revision selected by Enzyme-JAX's Enzyme dependency.
load(
    "@enzyme//third_party/hedron_compile_commands:workspace.bzl",
    hedron_compile_commands_workspace = "repo",
)

hedron_compile_commands_workspace()

load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")

hedron_compile_commands_setup()

load("@hedron_compile_commands//:workspace_setup_transitive.bzl", "hedron_compile_commands_setup_transitive")

hedron_compile_commands_setup_transitive()

load("@hedron_compile_commands//:workspace_setup_transitive_transitive.bzl", "hedron_compile_commands_setup_transitive_transitive")

hedron_compile_commands_setup_transitive_transitive()

load("@hedron_compile_commands//:workspace_setup_transitive_transitive_transitive.bzl", "hedron_compile_commands_setup_transitive_transitive_transitive")

hedron_compile_commands_setup_transitive_transitive_transitive()
