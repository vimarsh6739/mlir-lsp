package(default_visibility = ["//visibility:public"])

genrule(
    name = "copy-enzymexla-lsp-server",
    srcs = ["@enzyme_ad//:enzymexla-lsp-server"],
    outs = ["enzymexla-lsp-server"],
    cmd = "cp $(location @enzyme_ad//:enzymexla-lsp-server) $@",
    executable = True,
)
