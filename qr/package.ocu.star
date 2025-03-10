load("github.com/ocuroot/sdk/v0/package.star", "package")
load("github.com/ocuroot/sdk/v0/source.star", "source")
load("github.com/ocuroot/sdk/v0/machine.star", "host")
load("github.com/ocuroot/sdk/v0/policy.star", "ready", "later", "dependency")
load("//go.star", "setup_go")

# build creates a new build of this package
def build(ctx):
    # Build the binary
    go = setup_go()
    binary_path = "../.ocuroot/build/qr/{}/qr".format(ctx.build.sequence)
    go.build(".", binary_path)

    ctx.build.attributes["binary_path"] = binary_path

# deploy deploys a build in a given environment
def deploy(ctx):
    # Read the message as provided from the message package
    message = ctx.deploy.inputs["message"]

    host.shell("{} ../.ocuroot/deployments/{}/qr.png \"{}\"".format(ctx.build.attributes["binary_path"], ctx.environment.name, message))

    # Mark this build as staged to allow production deployment
    if ctx.environment.attributes.get("type") == "staging":
        ctx.build.annotations["staged"] = "true"

# policy defines the rules for deploying a build to a given environment
def policy(ctx):
    # Prevent deploying to production if not already staged
    if ctx.environment.attributes.get("type") == "prod" and ctx.build.annotations.get("staged") != "true":
        return later()

    return ready(
        inputs={
            "message": dependency(package="message", output="message"),
        },
    )

# Register the QR package
package(
  name="qr",
  build=build,
  policy=policy,
  deploy=deploy,
)

# Entropy: 6