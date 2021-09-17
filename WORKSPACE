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
    commit = "871a47d59ecb62e7c900111f04e155a5ddd3cb33",
    map_to = "adidoks",
    remote = "https://github.com/aaranxu/adidoks.git",
)

git_repository(
    name = "io_bazel_stardoc",
    remote = "https://github.com/bazelbuild/stardoc.git",
    tag = "0.4.0",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
