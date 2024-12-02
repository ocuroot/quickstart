load("github.com/ocuroot/sdk/v0/package.star", "package")
load("github.com/ocuroot/sdk/v0/source.star", "source")
load("github.com/ocuroot/sdk/v0/policy.star", "ready", "later")

# build creates a new build of this package
def build(build):
    # Store the message content as an attribute of the build
    message = source.read("message.txt")
    build.attributes["message"] = message

# deploy deploys a build in a given environment
def deploy(deploy, build, environment):
    # Write the message as an output for use in downstream packages
    deploy.outputs["message"] = build.attributes["message"].replace("$ENVIRONMENT", environment.name)

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

def destroy(deploy, build, environment):
    print("destroy - TODO")

# policy defines the rules for deploying a build to a given environment
def policy(build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
        return later()

    # No inputs required
    return ready()

# Register the message package
package(
  name="message",
  build=build,
  policy=policy,
  deploy=deploy,
  destroy=destroy
)

# Entropy: 2