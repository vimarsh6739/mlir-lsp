load(":workspace.bzl", "OVERRIDE_ENZYMEXLA_PATH")

package(default_visibility = ["//visibility:public"])

_ENZYMEXLA_SOURCE_MODE = "override" if OVERRIDE_ENZYMEXLA_PATH else "archive"

cc_binary(
    name = "mlir-lsp-server",
    srcs = ["mlir-lsp.cpp"],
    copts = [
        "-Wno-return-type",
        "-Wno-unused-variable",
    ],
    deps = [
        "@enzyme_ad//:enzymexla-registry",
        "@llvm-project//mlir:MlirLspServerLib",
        "@stablehlo//:interpreter_ops",
        "@stablehlo//stablehlo/tests:check_ops",
    ],
)

genrule(
    name = "write-enzymexla-source-mode",
    outs = ["enzymexla-source-mode"],
    cmd = "echo {} > $@".format(_ENZYMEXLA_SOURCE_MODE),
)
