ocuroot("0.3.0")

# Create a docker network for the environment

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

# up creates a docker network with the same name as this environment
def up(environment={}):
    network_exists = shell(
        "docker network ls | grep {}".format(environment["name"]), 
        mute=True, 
        continue_on_error=True
    ).exit_code == 0
    if not network_exists:
        shell("docker network create {}".format(environment["name"]))
    return done(
        outputs={
            "network_name": environment["name"],
        },
    )

# down removes the docker network for this environment
def down(environment={}):
    shell("docker network rm {}".format(environment["name"]), continue_on_error=True)
    return done()

#########################################
## Pipeline definition
## Defining the order of the pipeline
#########################################

phase(
    name="staging",
    tasks= [
        deploy(
            up=up,
            down=down,
            environment=e,
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
        ) for e in environments() if e.attributes["type"] == "production"
    ]
)