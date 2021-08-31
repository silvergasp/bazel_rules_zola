load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

_BUILD_FILE_CONTENT = """
load("@rules_zola//zola:defs.bzl", "zola_content_group")
exports_files(glob(["**/*"]))

zola_content_group(
    name = "theme",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
    strip_prefix = ".",
    prefix = "{name}",
)
"""

def git_theme(**attrs):
    map_to = attrs.pop("map_to", attrs["name"])
    new_git_repository(
        build_file_content = _BUILD_FILE_CONTENT.format(name = map_to),
        **attrs
    )

def http_theme(**attrs):
    map_to = attrs.pop("map_to", attrs["name"])
    http_archive(
        build_file_content = _BUILD_FILE_CONTENT.format(name = map_to),
        **attrs
    )
