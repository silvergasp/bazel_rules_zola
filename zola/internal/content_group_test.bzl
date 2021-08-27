load(":content_group.bzl", "ZolaContentGroupInfo", "map_zola_file", "zola_content_group")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _content_group_provider_content_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    expected_file_mapping = [map_zola_file(file = ctx.files.srcs[0], zola_prefix = ctx.attr.expected_zola_prefix)]
    asserts.equals(env, expected_file_mapping, target_under_test[ZolaContentGroupInfo].file_mapping.to_list())
    return analysistest.end(env)

content_group_provider_contents_test = analysistest.make(
    _content_group_provider_content_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            default = ["//zola/internal:test_file.md"],
        ),
        "expected_zola_prefix": attr.string(),
    },
)

def _content_group_provider_content_transitive_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    expected_file_mapping = [
        map_zola_file(
            file = ctx.files.transitive_srcs[0],
            zola_prefix = "content/zola/internal/transitive_test_file.md",
        ),
        map_zola_file(
            file = ctx.files.srcs[0],
            zola_prefix = "content/zola/internal/test_file.md",
        ),
    ]
    asserts.equals(
        env,
        expected_file_mapping,
        target_under_test[ZolaContentGroupInfo].file_mapping.to_list(),
    )
    return analysistest.end(env)

content_group_provider_contents_transitive_test = analysistest.make(
    _content_group_provider_content_transitive_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            default = ["//zola/internal:test_file.md"],
        ),
        "transitive_srcs": attr.label_list(
            allow_files = True,
            default = ["//zola/internal:transitive_test_file.md"],
        ),
    },
)

def _test_content_group_provider_contents():
    # Testing paths.
    zola_content_group(
        name = "__provider_contents_absolute_prefix",
        tags = ["manual"],
        strip_prefix = "//zola",
        prefix = "content",
        srcs = ["//zola/internal:test_file.md"],
    )
    content_group_provider_contents_test(
        name = "provider_content_absolute_prefix_test",
        target_under_test = "__provider_contents_absolute_prefix",
        expected_zola_prefix = "content/internal/test_file.md",
    )
    zola_content_group(
        name = "__provider_contents_relative_prefix",
        tags = ["manual"],
        strip_prefix = ".",
        prefix = "content",
        srcs = ["//zola/internal:test_file.md"],
    )
    content_group_provider_contents_test(
        name = "provider_content_relative_prefix_test",
        target_under_test = "__provider_contents_relative_prefix",
        expected_zola_prefix = "content/test_file.md",
    )

    # Testing transitive deps.
    zola_content_group(
        name = "__provider_contents_transitive",
        tags = ["manual"],
        prefix = "content",
        srcs = ["//zola/internal:transitive_test_file.md"],
    )
    zola_content_group(
        name = "__provider_contents_has_deps",
        tags = ["manual"],
        prefix = "content",
        deps = [":__provider_contents_transitive"],
        srcs = ["//zola/internal:test_file.md"],
    )

    content_group_provider_contents_transitive_test(
        name = "provider_content_transitive_test",
        target_under_test = "__provider_contents_has_deps",
    )

def content_group_test_suite(name):
    _test_content_group_provider_contents()
    native.test_suite(
        name = name,
        tests = [
            ":provider_content_relative_prefix_test",
            ":provider_content_absolute_prefix_test",
            ":provider_content_transitive_test",
        ],
    )
