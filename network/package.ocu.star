ocuroot("0.3.0")

# Create a docker network for the environment

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

# up creates a docker network with the same name as this environment
def up(ctx):
    network_exists = shell(
        "docker network ls | grep {}".format(ctx.inputs.environment["name"]), 
        mute=True, 
        continue_on_error=True
    ).exit_code == 0
    if not network_exists:
        shell("docker network create {}".format(ctx.inputs.environment["name"]))
    return done(
        outputs={
            "network_name": ctx.inputs.environment["name"],
        },
    )

# down removes the docker network for this environment
def down(ctx):
    shell("docker network rm {}".format(ctx.inputs.environment["name"]), continue_on_error=True)
    return done()

#########################################
## Pipeline definition
## Defining the order of the pipeline
#########################################

phase(
    name="staging",
    work= [
        deploy(
            up=up,
            down=down,
            environment=e,
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
        ) for e in environments() if e.attributes["type"] == "production"
    ]
)