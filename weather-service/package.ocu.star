ocuroot("0.3.0")

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

name = "quickstart-weather-service"

def build():
    shell("docker build . -t {}:latest".format(name))
    return done(
        outputs={
            "image": "{}:latest".format(name),
        },
    )

def up(environment={}, network_name="", image=""):
    container_name = "{}-{}".format(name, environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name), continue_on_error=True)
    shell("docker run -d --name {name} --network {network} {image}".format(
        name=container_name,
        network=network_name,
        image=image,
    ))
    return done()

def down(environment={}, network_name="", image=""):
    container_name = "{}-{}".format(name, environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name))
    return done()

#########################################
## Pipeline definition
## Defining the order of the pipeline
#########################################

task(
    name="build",
    fn=build
)

phase(
    name="staging",
    tasks= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./task/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "staging"
    ]
)

phase(
    name="production",
    tasks= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./task/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "production"
    ]
)