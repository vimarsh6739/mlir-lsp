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
