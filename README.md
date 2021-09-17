# Rules Zola 
[![CI](https://github.com/silvergasp/bazel_rules_zola/actions/workflows/ci.yml/badge.svg)](https://github.com/silvergasp/bazel_rules_zola/actions/workflows/ci.yml) [![docs](https://img.shields.io/badge/docs-passing-brightgreen)](https://silvergasp.github.io/bazel_rules_zola/)

**WARNING**: These rules are still under construction expect breaking changes.

A set of Bazel rules for building markdown sites using Zola. This is
particularly useful for integrating documentation generation into your build.

## Quickstart
Start by fetching the rules and deps via your WORKSPACE file. For further usage information please see the [rules_zola site](https://silvergasp.github.io/bazel_rules_zola).

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
```