# build creates a new build of this package
def build(build, repo):
    # Store the message content as an attribute of the build
    message = repo.read("message.txt")
    build.attributes["message"] = message

# deploy deploys a build in a given environment
def deploy(deploy, build, repo, docker, environment, schedule):
    # Write the message as an output for use in downstream packages
    deploy.outputs["message"] = build.attributes["message"].replace("$ENVIRONMENT", environment.name)

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

# policy defines the rules for deploying a build to a given environment
def policy(policy, build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
        return policy.later()

    # No inputs required
    return policy.ready()

# Register the message package
package(
  name="message",
  build=build,
  policy=policy,
  deploy=deploy,
)