genrule(
    name = "foo",
    srcs = [],
    outs = ["foo.txt"],
    cmd = "sleep 5 && echo 'Hello World!' > $@",
)

genrule(
    name = "envinfo",
    srcs = [
        "a.txt",
        "b.txt",
    ],
    outs = ["envinfo.txt"],
    cmd_bash = """(
        env
        echo "-----"
        pwd
        ls -l
        echo "-----"
        echo "whoami     = $$(whoami)"
        echo "TARGET_CPU = $(TARGET_CPU)"
        echo "BINDIR     = $(BINDIR)"
        echo "GENDIR     = $(GENDIR)"
        echo "OUTS       = $(OUTS)"
        echo "SRCS       = $(SRCS)"
        echo "RULEDIR    = $(RULEDIR)"
        echo "a.txt      = $(location :a.txt)"
        echo "b.txt      = $(location :b.txt)"
        ) | tee $@""",
)
