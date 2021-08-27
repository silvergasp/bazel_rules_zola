""" Zola site builder """

load(":content_group.bzl", "ZolaContentGroupInfo")

def zola_site_init(ctx):
    """ Initialises a Zola site 

    Args:
        ctx: Rule context.

    Returns:
        depset of files created during init
    """

    directory_paths = [
        "content",
        "sass",
        "static",
        "templates",
        "themes",
    ]
    directories = [
        ctx.actions.declare_directory(directory)
        for directory in directory_paths
    ]
    ctx.actions.run(
        outputs = directories,
        executable = "mkdir",
        arguments = directory_paths,
    )
    config = ctx.actions.declare_file("config.toml")
    ctx.actions.symlink(
        output = config,
        target_file = ctx.file.config,
    )
    return struct(directories = directories, config = config)

def zola_site_init_impl(ctx):
    init = zola_site_init(ctx)
    return DefaultInfo(files = depset(init.directories + [init.config]))

def _zola_site_impl(ctx):
    init_files = zola_site_init(ctx)

    default_outputs = [
        "public/404.html",
        "public/index.html",
        "public/robots.txt",
        "public/sitemap.xml",
        "public/site.css",
        "public/search_index.en.js",
        "public/elasticlunr.min.js",
    ]
    outputs = [ctx.actions.declare_file(output) for output in default_outputs]
    ctx.actions.run_shell(
        outputs = outputs,
        inputs = [init_files.config] + init_files.directories,
        tools = [ctx.executable._zola, ctx.executable._touch],
        command = "{_zola} --root {root} build && {_touch} {outputs}".format(
            _zola = ctx.executable._zola.path,
            _touch = ctx.executable._touch.path,
            root = init_files.config.dirname,
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
            providers = [ZolaContentGroupInfo],
        ),
        "sass": attr.label_list(
            providers = [ZolaContentGroupInfo],
        ),
        "static": attr.label_list(
            providers = [ZolaContentGroupInfo],
        ),
        "templates": attr.label_list(
            providers = [ZolaContentGroupInfo],
        ),
        "themes": attr.label_list(
            providers = [ZolaContentGroupInfo],
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
