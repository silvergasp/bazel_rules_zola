load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

_BUILD_FILE_CONTENT = """
filegroup(
    name = "theme",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)
"""

def git_theme(**attrs):
    git_repository(
        build_file_content = _BUILD_FILE_CONTENT,
        **attrs
    )

def http_theme(**attrs):
    http_archive(
        build_file_content = _BUILD_FILE_CONTENT,
        **attrs
    )
