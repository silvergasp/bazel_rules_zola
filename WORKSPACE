workspace(name = "rules_zola")

load("//:zola_deps.bzl", "zola_deps")

zola_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Set up host hermetic host toolchain.
git_repository(
    name = "rules_cc_toolchain",
    commit = "f2d8037997f3c52bec4815231e5b57c056367f23",
    remote = "https://github.com/silvergasp/rules_cc_toolchain.git",
)

load("@rules_cc_toolchain//:rules_cc_toolchain_deps.bzl", "rules_cc_toolchain_deps")

rules_cc_toolchain_deps()

load("@rules_cc_toolchain//cc_toolchain:cc_toolchain.bzl", "register_cc_toolchains")

register_cc_toolchains()

load("//zola:themes.bzl", "git_theme")

git_theme(
    name = "com_github_aaranxu_adidoks",
    commit = "4ac7b69f35f70a9a7694ab2663c79c67d26f03d1",
    map_to = "adidoks",
    remote = "https://github.com/aaranxu/adidoks.git",
)
