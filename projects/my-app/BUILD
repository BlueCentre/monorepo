py_library(
    name = "my_app",
    srcs = ["app.py"],
    # deps = [
    #     "//common/lib:common",
    # ],
)

py_binary(
    name = "image",
    srcs = ["image.py"],
    deps = [
        ":my_app",
    ],
)
