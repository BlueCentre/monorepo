py_library(
    name = "my_other_app",
    srcs = ["app.py"],
    # deps = [
    #     "//lib:common",
    # ],
)

py_binary(
    name = "image",
    srcs = ["image.py"],
    deps = [
        ":my_other_app",
    ],
)
