load("github.com/ocuroot/sdk/v0/machine.star", "host")

def setup_go():
    # Check if Go is installed and error out if not
    if host.shell("which go", continue_on_error=True).exit_code != 0:
        fail("Go is not installed")
        return

    repo_path = host.shell("pwd").stdout.strip()
    go_cache_dir = repo_path + "/../.ocuroot/cache/go/cache"
    go_path_dir = repo_path + "/../.ocuroot/cache/go/path"

    def build_func(target, output, ldflags=""):

        host.shell("""
            go build \
                -o $FILE \
                -ldflags="$LDFLAGS" \
                .
            """,
            env={
                "FILE": output,
                "LDFLAGS": ldflags,
                "GOFLAGS": "-buildvcs=false",
                "GOCACHE": go_cache_dir,
                "GOPATH": go_path_dir,
            })

    def test_func(targets, short=False):
        shortParam = ""
        if short:
            shortParam = " -short "
        host.shell("go test {} {}".format(shortParam, targets), env={
            "GOCACHE": go_cache_dir,
            "GOPATH": go_path_dir,
        })

    return struct(
        test=test_func,
        build=build_func,
        exec=host.shell,
    )
