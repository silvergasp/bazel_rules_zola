+++
title = "Quick Start"
description = "One page summary of how to start a new Zola project with Bazel."
date = 2021-05-01T08:20:00+00:00
updated = 2021-05-01T08:20:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "One page summary of how to start a new Zola project with Bazel."
toc = true
top = false
+++


## Setup 
Start by fetching the rules and deps via your WORKSPACE file.

```py
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Fetch zola rules.
git_repository(
    name = "rules_zola",
    commit = "8d94fbd46c4738b9b8b0dcba62f222bd97be8c60",
    remote = "https://github.com/silvergasp/bazel_rules_zola.git",
)

load("@rules_zola//:zola_deps.bzl", "zola_deps")

# Fetch Zola dependencies for your machine.
zola_deps()

load("@rules_zola//zola:themes.bzl", "git_theme")

# Fetch theme for your site.
git_theme(
    name = "com_github_aaranxu_adidoks",
    commit = "4ac7b69f35f70a9a7694ab2663c79c67d26f03d1",
    map_to = "adidoks",
    remote = "https://github.com/aaranxu/adidoks.git",
)
```

## Creating a Zola site
Here we use the `zola_site` rule to generate a site. Site content, static files
and sass can be managed using the `zola_content_group` rule.

```py 
# //docs:BUILD.bazel
load("@rules_zola//zola:defs.bzl", "zola_site")

load("//zola:defs.bzl", "zola_site")

zola_site(
    name = "site",
    config = "config.toml",
    content = ["//docs/content"],
    theme = "adidoks",
    themes = ["@com_github_aaranxu_adidoks//:theme"],
)
```

Add some content to your new site. e.g.

```py 
# //docs/content:BUILD.bazel
load("//zola:defs.bzl", "zola_content_group")

zola_content_group(
    name = "content",
    srcs = glob([
        "**/*.md",
    ]),
    strip_prefix = ".",
    visibility = ["//visibility:public"],
)
```
