""" Zola rule definitions. """

load(
    "@rules_zola//zola/internal:content_group.bzl",
    _zola_content_group = "zola_content_group",
)

zola_content_group = _zola_content_group
