""" Zola site builder """

load(":content_group.bzl", "ZolaContentGroupInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _site_path(ctx, path = ""):
    return paths.join(ctx.label.name + "_site_content", path)

def _generated_html_path(ctx, path = ""):
    return "/".join([ctx.label.name, path])

def zola_site_init(ctx):
    """ Initialises a Zola site 

    Args:
        ctx: Rule context.

    Returns:
        depset of files created during init
    """

    config = ctx.actions.declare_file(_site_path(ctx, "config.toml"))
    ctx.actions.symlink(
        output = config,
        target_file = ctx.file.config,
    )
    return config

def zola_site_init_impl(ctx):
    return DefaultInfo(files = depset([zola_site_init(ctx)]))

def zola_declare_files(ctx, deps, zola_directory = ""):
    """ Declares files for a Zola site 

    Args:
        ctx: Rule context.
        deps: Dependencies to declare.
        zola_directory: Directory to declare files in.

    Returns:
        List of declared input files.
    """
    content = [dep[ZolaContentGroupInfo] for dep in deps]

    file_mapping = depset(transitive = [
        dep.file_mapping
        for dep in content
    ])

    content_files = []
    for map in file_mapping.to_list():
        if not zola_directory:
            normalised_zola_directory = ""
        else:
            normalised_zola_directory = zola_directory + "/"

        zola_path = _site_path(
            ctx,
            normalised_zola_directory + map.zola_prefix,
        )
        content_output_file = ctx.actions.declare_file(zola_path)
        content_files.append(content_output_file)
        ctx.actions.symlink(
            output = content_output_file,
            target_file = map.file,
        )
    return content_files

def zola_declare_content(ctx):
    return zola_declare_files(ctx, ctx.attr.content, "content")

def zola_declare_themes(ctx):
    return zola_declare_files(ctx, ctx.attr.themes, "themes")

def zola_declare_static(ctx):
    return zola_declare_files(ctx, ctx.attr.static, "static")

def zola_declare_sass(ctx):
    return zola_declare_files(ctx, ctx.attr.sass, "sass")

def zola_declare_templates(ctx):
    return zola_declare_files(ctx, ctx.attr.templates, "templates")

def _zola_site_impl(ctx):
    config = zola_site_init(ctx)
    content = zola_declare_content(ctx)
    themes = zola_declare_themes(ctx)
    static = zola_declare_static(ctx)
    sass = zola_declare_sass(ctx)
    templates = zola_declare_templates(ctx)
    root = config.dirname

    default_outputs = [
        # _generated_html_path(ctx),
        _generated_html_path(ctx, "404.html"),
        _generated_html_path(ctx, "index.html"),
        _generated_html_path(ctx, "robots.txt"),
        _generated_html_path(ctx, "sitemap.xml"),
        _generated_html_path(ctx, "main.css"),
        _generated_html_path(ctx, "search_index.en.js"),
        _generated_html_path(ctx, "elasticlunr.min.js"),
    ]

    content_outputs = [
        _generated_html_path(
            ctx,
            paths.relativize(content_file.path, root)[len("content/"):]
                .replace(".md", "/index.html")
                .replace("_", "-"),
        )
        for content_file in content
        if content_file.basename != "_index.md"
    ]
    static_outputs = [
        _generated_html_path(
            ctx,
            paths.relativize(static_file.path, root)[len("static/"):],
        )
        for static_file in static
    ]
    theme_static_inputs = [
        file
        for file in themes
        if ctx.attr.theme + "/static/" in file.short_path
    ]
    theme_static_outputs = [
        _generated_html_path(
            ctx,
            paths.relativize(static_file.path, root),
        ).replace(
            "themes/" + ctx.attr.theme + "/static",
            "",
        )
        for static_file in theme_static_inputs
    ]
    css_outputs = [
        _generated_html_path(
            ctx,
            paths.relativize(sass_file.path, root),
        )
        for sass_file in sass
    ]
    theme_css_inputs = [
        file
        for file in themes
        if ctx.attr.theme + "/sass/" in file.short_path and
           file.basename.endswith(".scss") and
           not file.basename.startswith("_")
    ]
    theme_css_outputs = [
        _generated_html_path(
            ctx,
            paths.relativize(css_file.path, root),
        ).replace(
            "themes/" + ctx.attr.theme + "/sass/",
            "",
        ).replace(".scss", ".css")
        for css_file in theme_css_inputs
    ]
    outputs = [
        ctx.actions.declare_file(output)
        for output in default_outputs +
                      content_outputs +
                      theme_static_outputs +
                      static_outputs +
                      theme_css_outputs +
                      css_outputs
    ]
    ctx.actions.run_shell(
        outputs = outputs,
        inputs = [config] + content + themes + static + sass + templates,
        tools = [ctx.executable._zola, ctx.executable._touch],
        command = """  
{_zola} --root {root} build -o {output_directory} && \
{_touch} {outputs}""".format(
            _zola = ctx.executable._zola.path,
            _touch = ctx.executable._touch.path,
            root = root,
            output_directory = paths.join(ctx.bin_dir.path, ctx.label.package, ctx.label.name),
            outputs = " ".join([output.path for output in outputs]),
        ),
        progress_message = "Building site: " + str(ctx.label),
    )

    return [DefaultInfo(
        files = depset(outputs),
    )]

zola_site = rule(
    _zola_site_impl,
    attrs = {
        "config": attr.label(
            doc = "The sites config.toml",
            allow_single_file = [".toml"],
            mandatory = True,
        ),
        "content": attr.label_list(
            doc = "List of zola_content_groups.",
            providers = [ZolaContentGroupInfo],
        ),
        "sass": attr.label_list(
            doc = "Site sass style sheets.",
            providers = [ZolaContentGroupInfo],
        ),
        "static": attr.label_list(
            doc = "Static content.",
            providers = [ZolaContentGroupInfo],
        ),
        "templates": attr.label_list(
            doc = "Site templates.",
            providers = [ZolaContentGroupInfo],
        ),
        "themes": attr.label_list(
            doc = "A list of themes to add to this site. This is useful for \
themes that inherit from others. This should be used with the 'theme' attribute.",
            providers = [ZolaContentGroupInfo],
        ),
        "theme": attr.string(
            doc = "The theme that is specified in the config.toml.",
        ),
        "_zola": attr.label(
            doc = "The zola executable",
            allow_single_file = True,
            executable = True,
            default = "@rules_zola//zola",
            cfg = "exec",
        ),
        "_touch": attr.label(
            doc = "The touch executable",
            allow_single_file = True,
            executable = True,
            default = "@rules_zola//tools/touch",
            cfg = "exec",
        ),
    },
)
