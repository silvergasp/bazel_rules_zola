""" Test suite for the site builder """

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load(":site.bzl", "zola_site", "zola_site_init_impl")
load(":content_group.bzl", "zola_content_group")

zola_site_init_internal = rule(
    implementation = zola_site_init_impl,
    attrs = {
        "config": attr.label(
            allow_single_file = True,
            default = "@rules_zola//zola/internal:test_config.toml",
        ),
        "_zola": attr.label(
            allow_single_file = True,
            default = "@rules_zola//zola:zola",
            cfg = "exec",
            executable = True,
        ),
    },
    doc = "This rule is for test purposes only and should never be invoked.",
)

def _correct_init_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    actions = analysistest.target_actions(env)
    asserts.equals(env, 1, len(actions))
    config_action = actions[-1].outputs.to_list()[0]
    asserts.equals(
        env,
        "config.toml",
        config_action.basename,
    )
    return analysistest.end(env)

correct_init_test = analysistest.make(_correct_init_impl)

def _inspect_actions_init_test():
    zola_site_init_internal(
        name = "__init",
        tags = ["manual"],
    )
    correct_init_test(
        name = "site_init",
        target_under_test = ":__init",
    )

def _site_build_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    actions = analysistest.target_actions(env)

    # Single build action.
    asserts.equals(env, 2, len(actions))

    # Minimal default outputs.
    all_outputs = []
    for action in actions:
        all_outputs.extend([
            out.short_path
            for out in action.outputs.to_list()
        ])
    minimal_expected_outputs = [
        "zola/internal/__site_build_test_nodeps/" + path
        for path in [
            "404.html",
            "index.html",
            "robots.txt",
            "sitemap.xml",
        ]
    ]
    for output in minimal_expected_outputs:
        asserts.true(env, output in all_outputs)
    return analysistest.end(env)

site_build_test = analysistest.make(_site_build_test_impl)

def _site_build_nodeps_test():
    zola_site(
        name = "__site_build_test_nodeps",
        config = "//zola/internal:test_config.toml",
    )
    site_build_test(
        name = "site_build_nodeps_test",
        target_under_test = ":__site_build_test_nodeps",
    )

def _site_build_content_integration_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    actions = analysistest.target_actions(env)
    expected_content_outputs = [
        "zola/internal/__site_build_content_integration_test/zola/internal/test-file/index.html",
        "zola/internal/__site_build_content_integration_test/transitive/transitive-test-file/index.html",
    ]
    all_outputs = []
    for action in actions:
        all_outputs.extend([
            out.short_path
            for out in action.outputs.to_list()
        ])
    for output in expected_content_outputs:
        asserts.true(env, output in all_outputs)

    return analysistest.end(env)

site_build_content_integration_test = analysistest.make(_site_build_content_integration_test_impl)

def _site_build_content_integration_test():
    zola_content_group(
        name = "__site_build_integration_transitive_content",
        srcs = ["transitive_test_file.md"],
        strip_prefix = ".",
        prefix = "transitive",
    )
    zola_content_group(
        name = "__site_build_integration_content",
        srcs = ["test_file.md"],
        deps = [":__site_build_integration_transitive_content"],
    )
    zola_site(
        name = "__site_build_content_integration_test",
        config = "//zola/internal:test_config.toml",
        content = [":__site_build_integration_content"],
    )
    site_build_content_integration_test(
        name = "site_build_content_integration_test",
        target_under_test = ":__site_build_content_integration_test",
    )

def _build_site_theme_integration_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    actions = analysistest.target_actions(env)

    # Minimal default outputs.
    all_inputs = []
    for action in actions:
        all_inputs.extend([
            input.short_path
            for input in action.inputs.to_list()
        ])
    minimal_expected_input = [
        "zola/internal/__site_build_theme_integration_test_site_content/themes/adidoks/config.toml",
        "zola/internal/__site_build_theme_integration_test_site_content/themes/adidoks/config.toml",
        "zola/internal/__site_build_theme_integration_test_site_content/themes/adidoks/README.md",
    ]
    for input in minimal_expected_input:
        asserts.true(env, input in all_inputs)
    return analysistest.end(env)

site_build_theme_integration_test = analysistest.make(_build_site_theme_integration_test_impl)

def _site_build_theme_integration_test():
    zola_site(
        name = "__site_build_theme_integration_test",
        config = "//zola/internal:test_config_adidoks.toml",
        themes = ["@com_github_aaranxu_adidoks//:theme"],
    )
    site_build_theme_integration_test(
        name = "site_build_theme_integration_test",
        target_under_test = ":__site_build_theme_integration_test",
    )

def site_test_suite(name):
    _inspect_actions_init_test()
    _site_build_nodeps_test()
    _site_build_content_integration_test()
    _site_build_theme_integration_test()

    native.test_suite(
        name = name,
        tests = [
            ":site_init",
            ":site_build_nodeps_test",
            ":site_build_content_integration_test",
            ":site_build_theme_integration_test",
        ],
    )
