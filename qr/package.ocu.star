load("//go.star", "setup_go")

def build(build, repo, docker):
    # Build the binary
    go = setup_go(docker, "golang:1.23.1-bullseye")
    binary_path = "../.ocuroot/build/qr/{}/qr".format(build.sequence)
    go.build(".", binary_path)

    build.attributes["binary_path"] = binary_path

def deploy(deploy, build, repo, docker, environment, schedule):
    # Read the message as provided from the message package
    message = deploy.inputs["message"]
    message = message.replace("$ENVIRONMENT", environment.name)

    run = docker.pull("alpine").container()
    run.exec("{} ../.ocuroot/deployments/{}/qr.png \"{}\"".format(build.attributes["binary_path"], environment.name, message))

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

def policy(policy, build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
        return policy.later()

    return policy.ready(
        message=policy.input_dependency(package="message", output="message"),
    )

package(
  name="qr",
  build=build,
  policy=policy,
  deploy=deploy,
)