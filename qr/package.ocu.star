load("github.com/ocuroot/sdk/v0/package.star", "package")
load("github.com/ocuroot/sdk/v0/source.star", "source")
load("github.com/ocuroot/sdk/v0/machine.star", "host")
load("github.com/ocuroot/sdk/v0/policy.star", "ready", "later", "dependency")
load("//go.star", "setup_go")

# build creates a new build of this package
def build(build):
    # Build the binary
    go = setup_go()
    binary_path = "../.ocuroot/build/qr/{}/qr".format(build.sequence)
    go.build(".", binary_path)

    build.attributes["binary_path"] = binary_path

# deploy deploys a build in a given environment
def deploy(deploy, build, environment):
    # Read the message as provided from the message package
    message = deploy.inputs["message"]

    host.shell("pwd")
    host.shell("ls -la {}".format(build.attributes["binary_path"]))
    host.shell("{} ../.ocuroot/deployments/{}/qr.png \"{}\"".format(build.attributes["binary_path"], environment.name, message))

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

def destroy(deploy, build, repo, docker, environment):
    print("destroy - TODO")

# policy defines the rules for deploying a build to a given environment
def policy(build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
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
  destroy=destroy,
)

# Entropy: 3