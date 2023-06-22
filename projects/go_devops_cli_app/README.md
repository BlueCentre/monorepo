# Overview

Template for creating Golang projects.

## Roadmap

- [x] Setup basic templating
    - [x] Use latest bazel and modules including rules_oci (using workaround custom build script)
    - [x] Use latest skaffold with bazel build
- [ ] Research Cookiecutter
- [ ] Bake-in everything including best practices
- [ ] Test and validate framework
- [ ] Gather feedback from beta testers

## Known issues

- [ ] skaffold dev does not yet work with latest rules_oci
    - [ ] bazel-contrib/rules_oci issue [#265](https://github.com/bazel-contrib/rules_oci/issues/265)
