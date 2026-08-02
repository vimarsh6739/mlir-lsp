load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_visibility = ["//visibility:public"])

cc_binary(
    name = "mlir-lsp",
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

refresh_compile_commands(
    name = "refresh_compile_commands",
    targets = ["//:mlir-lsp"],
)

sh_test(
    name = "mlir-lsp-help-test",
    srcs = ["tests/mlir-lsp-help-test.sh"],
    data = [":mlir-lsp"],
)
