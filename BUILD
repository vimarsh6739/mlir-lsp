load(":workspace.bzl", "OVERRIDE_ENZYMEXLA_PATH")

package(default_visibility = ["//visibility:public"])

_ENZYMEXLA_SOURCE_MODE = "override" if OVERRIDE_ENZYMEXLA_PATH else "archive"

genrule(
    name = "copy-enzymexla-lsp-server",
    srcs = ["@enzyme_ad//:enzymexla-lsp-server"],
    outs = ["enzymexla-lsp-server"],
    cmd = "cp $(location @enzyme_ad//:enzymexla-lsp-server) $@",
    executable = True,
)

genrule(
    name = "write-enzymexla-source-mode",
    outs = ["enzymexla-source-mode"],
    cmd = "echo {} > $@".format(_ENZYMEXLA_SOURCE_MODE),
)
