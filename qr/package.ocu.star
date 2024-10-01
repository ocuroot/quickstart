load("//go.star", "setup_go")

def build(build, repo):
    # Build the binary
    go = setup_go(docker, "golang:1.23-bullseye")
    go.build(".", "../.ocuroot/build/qr/{}/qr".format(build.sequence))

def deploy(deploy, build, repo, docker, environment, schedule):
    # Read the message as provided from the message package
    message = deploy.inputs["message"]

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

def policy(policy, build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
        return policy.later()

    return policy.ready(

    )

package(
  name="qr",
  build=build,
  policy=policy,
  deploy=deploy,
)