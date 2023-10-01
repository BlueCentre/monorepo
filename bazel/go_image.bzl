# See: https://codilime.com/blog/bazel-build-system-build-containerized-applications/
# State: Only for reference!
# Usage: Project BUILD.bazel
# load("//bazel:go_image.bzl", "go_image")
# go_image(
#     name = "app",
#     srcs = ["app.go"],
# )

load("@rules_go//go:def.bzl", "go_binary")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_oci//oci:defs.bzl", "oci_image")

def go_image(name, base = "@distroless_base", tars = [], **kwargs):
    '''
    Creates a containerized binary from Go sources.
    Parameters:
        name:  name of the image
        base: base image
        tars: additional image layers
        kwargs: arguments passed to the go_binary target
    '''
    binary_name = "{}_binary".format(name)
    layer_name = "{}_layer".format(name)
    image_name = "{}_image".format(name)

    go_binary(
        name = binary_name,
        **kwargs
    )

    pkg_tar(
        name = layer_name,
        srcs = [binary_name],
        package_dir = "/",
    )

    oci_image(
        name = image_name,
        tars = [layer_name] + tars,
        entrypoint = ["/{}".format(binary_name)],
        base = base,
    )
