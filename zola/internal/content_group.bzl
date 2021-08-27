""" A set of rules for structuring content in a Zola site """

load("@bazel_skylib//lib:paths.bzl", "paths")

ZolaFileMapInfo = provider(
    "Mapping of a single file from Bazel->Zola tree.",
    fields = {
        "file": "Bazel file.",
        "zola_prefix": "The path in the Zola tree.",
    },
)

def map_zola_file(file, zola_prefix):
    """ Constructs a Zola mapping from Bazel->Zola tree 

    Args:
        file: The Bazel file to map.
        zola_prefix: The path in the Zola tree.

    Returns:
        A ZolaFileMapInfo provider.
    """
    if type(zola_prefix) != type(""):
        fail("Zola path should be of type 'str'.")
    valid_prefixectories = [
        "content",
        "sass",
        "static",
        "templates",
        "themes",
    ]
    if zola_prefix.split("/")[0] not in valid_prefixectories:
        fail("Zola path should start with oneof, %s. Got path: %s" %
             (", ".join(valid_prefixectories), zola_prefix))
    return ZolaFileMapInfo(
        file = file,
        zola_prefix = zola_prefix,
    )

ZolaContentGroupInfo = provider(
    "How a group of files should be represented in the Zola tree.",
    fields = {
        "file_mapping": "depset(ZolaFileMapInfo) A set of files to map from\
 Bazel->Zola.",
    },
)

def map_zola_content_group(file_mapping):
    """ Constructs a ZolaContentGroupInfo provider mapping a group of files. 

    Args:
        file_mapping(iterable): A set of ZolaFileMapInfo providers.

    Returns:
        A ZolaContentGroupInfo provider.
    """
    return ZolaContentGroupInfo(depset(file_mapping))

def _strip_prefix(file, prefix):
    if prefix == "":
        return file.short_path
    elif prefix.startswith("//"):
        return paths.relativize("//" + file.short_path, prefix)
    else:
        return paths.relativize(
            file.short_path,
            paths.join(file.owner.package, prefix),
        )

def _zola_content_group_impl(ctx):
    file_mapping = []
    for file in ctx.files.srcs:
        file_mapping.append(map_zola_file(
            file = file,
            zola_prefix = paths.join(
                ctx.attr.prefix,
                _strip_prefix(file, ctx.attr.strip_prefix),
            ),
        ))
    return [
        DefaultInfo(files = depset(
            ctx.files.srcs,
            transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps],
        )),
        ZolaContentGroupInfo(file_mapping = depset(
            file_mapping,
            transitive = [dep[ZolaContentGroupInfo].file_mapping for dep in ctx.attr.deps],
        )),
    ]

zola_content_group = rule(
    _zola_content_group_impl,
    attrs = {
        "strip_prefix": attr.string(
            doc = "Prefix to strip from this targets path. To strip a path \
from the workspace root add '//' to the start of the path to strip otherwise\
it is assumed that the strip should be relative to the current directory e.g. \
strip_prefix = '.', will just place the file directly in the Zola directory.",
        ),
        "prefix": attr.string(
            doc = "The prefix to add to this content group when in the Zola tree.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "The srcs to add to this content group.",
        ),
        "deps": attr.label_list(
            doc = "The content that this group depends on.",
            providers = [ZolaContentGroupInfo],
        ),
    },
    provides = [DefaultInfo, ZolaContentGroupInfo],
    doc = "Specifies a group of files that should be mapped into the Zola tree.",
)
