load("github.com/ocuroot/sdk/v0/package.star", "package")
load("github.com/ocuroot/sdk/v0/source.star", "source")
load("github.com/ocuroot/sdk/v0/policy.star", "ready", "later")

# build creates a new build of this package
def build(ctx):
    # Store the message content as an attribute of the build
    message = source.read("message.txt")
    ctx.build.attributes["message"] = message

# deploy deploys a build in a given environment
def deploy(ctx):
    # Write the message as an output for use in downstream packages
    ctx.deploy.outputs["message"] = ctx.build.attributes["message"].replace("$ENVIRONMENT", ctx.environment.name)

    # Mark this build as staged to allow production deployment
    if ctx.environment.attributes.get("type") == "staging":
        ctx.build.annotations["staged"] = "true"

# policy defines the rules for deploying a build to a given environment
def policy(ctx):
    # Prevent deploying to production if not already staged
    if ctx.environment.attributes.get("type") == "prod" and ctx.build.annotations.get("staged") != "true":
        return later()

    # No inputs required
    return ready()

# Register the message package
package(
  name="message",
  build=build,
  policy=policy,
  deploy=deploy,
)

# Entropy: 7