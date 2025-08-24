ocuroot("0.3.0")

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

name = "quickstart-message-service"

def build(ctx):
    shell("docker build . -t {}:latest".format(name))
    return done(
        outputs={
            "image": "{}:latest".format(name),
        },
    )

def up(ctx):
    container_name = "{}-{}".format(name, ctx.inputs.environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name), continue_on_error=True)
    shell("docker run -d --name {name} --network {network} {image}".format(
        name=container_name,
        network=ctx.inputs.network_name,
        image=ctx.inputs.image,
    ))
    return done()

def down(ctx):
    container_name = "{}-{}".format(name, ctx.inputs.environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name))
    return done()

#########################################
## Pipeline definition
## Defining the order of the pipeline
#########################################

call(
    name="build",
    fn=build
)

phase(
    name="staging",
    work= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./call/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "staging"
    ]
)

phase(
    name="production",
    work= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./call/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "production"
    ]
)