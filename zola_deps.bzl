""" Third party dependencies for this project. """

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def zola_deps():
    """ Fetches the dependencies for the zola project. """
    if "zola-v0-14-1-x86-64-unknown-linux-gnu" not in native.existing_rules():
        http_archive(
            name = "zola-v0-14-1-x86-64-unknown-linux-gnu",
            url = "https://github.com/getzola/zola/releases/download/v0.14.1/zola-v0.14.1-x86_64-unknown-linux-gnu.tar.gz",
            build_file = "@rules_zola//third_party:zola-v0-14-1-x86-64-unknown-linux-gnu.BUILD",
            sha256 = "4223f57d9b60ad7217c44a815fa975b2229f692b7ef3de4b7ce61f1634e8dc33",
        )
    if "zola-v0-14-1-x86_64-apple-darwin" not in native.existing_rules():
        http_archive(
            name = "zola-v0-14-1-x86_64-apple-darwin",
            url = "https://github.com/getzola/zola/releases/download/v0.14.1/zola-v0.14.1-x86_64-apple-darwin.tar.gz",
            build_file = "@rules_zola//third_party:zola-v0-14-1-x86_64-apple-darwin.BUILD",
            sha256 = "754d5e1b4ca67a13c6cb4741dbff5b248075f4f4a0353d6673aa4f5afb7ec0bf",
        )
    if "zola-v0-14-1-x86_64-pc-windows-msvc" not in native.existing_rules():
        http_archive(
            name = "zola-v0-14-1-x86_64-pc-windows-msvc",
            url = "https://github.com/getzola/zola/releases/download/v0.15.3/zola-v0.15.3-x86_64-pc-windows-msvc.zip",
            build_file = "@rules_zola//third_party:zola-v0-14-1-x86_64-pc-windows-msvc.BUILD",
            sha256 = "d806e1e2e954369f350b6de9d755374fb57f8e820bf8e8df18e6c2db9daf9443",
        )
    if "bazel_skylib" not in native.existing_rules():
        http_archive(
            name = "bazel_skylib",
            sha256 = "af87959afe497dc8dfd4c6cb66e1279cb98ccc84284619ebfec27d9c09a903de",
            urls = [
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.0/bazel-skylib-1.2.0.tar.gz",
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.0/bazel-skylib-1.2.0.tar.gz",
            ],
        )
