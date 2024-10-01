def build(build, repo):
    # Store the message content as an attribute of the build
    message = repo.read("message.txt")
    build.attributes["message"] = message

def deploy(deploy, build, repo, docker, environment, schedule):
    # Write the message as an output for use in downstream packages
    deploy.outputs["message"] = build.attributes["message"]

    # Mark this build as staged to allow production deployment
    if environment.attributes.get("type") == "staging":
        build.annotations["staged"] = "true"

def policy(policy, build, environment):
    # Prevent deploying to production if not already staged
    if environment.attributes.get("type") == "prod" and build.annotations.get("staged") != "true":
        return policy.later()

    return policy.ready()

package(
  name="message",
  build=build,
  policy=policy,
  deploy=deploy,
)