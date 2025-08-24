ocuroot("0.3.0")

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

def build(ctx):
    shell("docker build . -t quickstart-frontend:latest")
    return done(
        outputs={
            "image": "quickstart-frontend:latest",
        },
    )

def up(ctx):
    container_name = "quickstart-frontend-{}".format(ctx.inputs.environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name), continue_on_error=True)
    shell("""docker run -d \
    --name {name} \
    --network {network} \
    -p {port}:8080 \
    -e TIME_SERVICE_URL=http://quickstart-time-service-{environment_name}:8080 \
    -e WEATHER_SERVICE_URL=http://quickstart-weather-service-{environment_name}:8080 \
    -e MESSAGE_SERVICE_URL=http://quickstart-message-service-{environment_name}:8080 \
    -e ENVIRONMENT={environment_name} \
    {image}""".format(
        name=container_name,
        network=ctx.inputs.network_name,
        port=ctx.inputs.environment["attributes"]["frontend_port"],
        image=ctx.inputs.image,
        environment_name=ctx.inputs.environment["name"],
    ))
    return done()

def down(ctx):
    container_name = "quickstart-frontend-{}".format(ctx.inputs.environment["name"])
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