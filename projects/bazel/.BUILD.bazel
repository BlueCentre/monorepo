genrule(
    name = "foo",
    srcs = [],
    outs = ["foo.txt"],
    cmd = "sleep 5 && echo 'Hello World!' > $@",
)

genrule(
    name = "envinfo",
    srcs = [
        "files/a.txt",
        "files/b.txt",
    ],
    outs = ["envinfo.txt"],
    cmd_bash = """(
        echo "-----ENV INFO----"
        echo "ENV:"
        env
        echo "-----FILESYSTEM INFO----"
        echo "PWD: `pwd`"
        echo "Files:"
        ls -laF
        echo "-----DEBUG INFO----"
        echo "whoami     = $$(whoami)"
        echo "TARGET_CPU = $(TARGET_CPU)"
        echo "BINDIR     = $(BINDIR)"
        echo "GENDIR     = $(GENDIR)"
        echo "OUTS       = $(OUTS)"
        echo "SRCS       = $(SRCS)"
        echo "RULEDIR    = $(RULEDIR)"
        echo "a.txt      = $(location :files/a.txt)"
        echo "b.txt      = $(location :files/b.txt)"
        ) | tee $@""",
)
