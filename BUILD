load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")

package(default_visibility = ["//visibility:public"])

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

refresh_compile_commands(
    name = "refresh_compile_commands",
    targets = ["//:mlir-lsp-server"],
)
