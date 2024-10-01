def setup_go(docker, image):
    go = docker.pull("golang:1.22.5-bullseye").container()
    go = go.cache("go", "/go/cache")
    go = go.cache("gopath", "/go/path")
    go = go.env(
        {
            "GOFLAGS": "-buildvcs=false",
            "GOCACHE": "/go/cache",
            "GOPATH": "/go/path",
        },
    )

    def build_func(target, output, os="linux", arch="amd64", ldflags=""):
        go.exec("""
            go build \
                -o {file} \
                -ldflags="{ldflags}" \
                .
            """.format(file=output,ldflags=ldflags),
            env={
                "GOOS": os,
                "GOARCH": arch,
            })

    def test_func(targets, short=False):
        shortParam = ""
        if short:
            shortParam = " -short "
        go.exec("go test {} {}".format(shortParam, targets))

    return struct(
        test=test_func,
        build=build_func,
        exec=go.exec,
    )
