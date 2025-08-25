# Ocuroot Quickstart

## Overview

This quickstart repo introduces to the open-source [Ocuroot client](https://github.com/ocuroot/ocuroot) by
building and deploying a set of interrelated services to a local Docker instance.

Through deploying these services, you'll see how Ocuroot manages missing dependencies, adding and populating new
environments and deleting environments.

Ordinarily, you may prefer to manage local containers with `docker compose`, but in this example, we'll be deploying
everything separately to illustrate how Ocuroot would operate in your datacenter or cloud environments.

## Prerequisites

You will need the following installed on your local machine:

* Docker
* Git
* Ocuroot client - see [installation instructions](https://github.com/ocuroot/ocuroot?tab=readme-ov-file#installation)

## Instructions

### 0. Clone the quickstart repository

We'll be working on a local copy of this repo, so you'll need to clone it.

```bash
git clone git@github.com:ocuroot/quickstart.git
cd quickstart
```

### 1. Create environments

Before we can deploy our services, we need somewhere to deploy them to. We need an environment.

For the quickstart, we have a config file that will do that for you, `environments.ocu.star`.

Kick off a release from that file to create a staging environment:

```bash
ocuroot release new environments.ocu.star
```

To get us started, this only creates a staging environment.
You can see the staging environment config by viewing the state:

```bash
$ ocuroot state get @/environment/staging
{
  "attributes": {
    "frontend_port": "8080",
    "type": "staging"
  },
  "name": "staging"
}
```

### 2. Release the frontend

Now we have an environment, we can release something to it. We'll start with the
"frontend" service.

```bash
ocuroot release new frontend/package.ocu.star
```

This should output something like this:

```bash
✓ build (934.371792ms)
  Outputs
  └── quickstart/-/frontend/package.ocu.star/@9/call/build#output/image
      └── quickstart-frontend:latest
› deploy to staging
  Pending Inputs
  └── quickstart/-/network/package.ocu.star/@/deploy/staging#output/network_name
```

The staging deployment has a pending input from `network/package.ocu.star`. This is
because we need a shared docker network for the staging environment.

### 3. Release network and complete frontend deployment

To satisfy the dependency for the frontend, we need to release the network.

```bash
ocuroot release new network/package.ocu.star
```

Once this succeeds, the network name will be available and you can continue the frontend deployment.
To continue any outstanding work, you can run the following command:

```bash
ocuroot work any
```

The frontend should now be running and you can view it at http://localhost:8080. You'll see three
errors about unreachable services, this is because we need to deploy them!

### 4. Release backend services

Run these three commands to deploy the backend services.

```bash
ocuroot release new time-service/package.ocu.star
ocuroot release new weather-service/package.ocu.star
ocuroot release new message-service/package.ocu.star
```

Once complete, reload the frontend and you'll see messages from these services.

### 7. Add a production environment

Now we have our staging environment fully populated and visually tested, we can
set up production!

Add the following to `environments.ocu.star`:

```star
register_environment(environment(
    name="production",
    attributes={
        "type": "production",
        "frontend_port": "8081",
    }
))
```

Then release these changes and deploy all services.

```bash
ocuroot release new environments.ocu.star
ocuroot work any
ocuroot work any
```

The second `ocuroot work any` call is needed to handle the dependency between `frontend` and `network`.

Once this is complete, you'll be able to load the production frontend at http://localhost:8081, 
there should be a line on the page indicating that the environment is "production".

### 8. Delete environments

You'll now have a bunch of containers running in your local Docker.
View the list by running `docker ps -f name=^quickstart-`. You'll see containers for both production
and staging.

Let's clean up after ourselves, first off, we'll delete our production environment. We'll do this
by removing it from our intent, and executing work to synchronize to actual state.

```bash
ocuroot state delete +/environments/production
ocuroot work any
```

If you run `docker ps -f name=^quickstart-` again, you'll only see the staging containers. 
See if you can adapt the above commands to delete the staging environment as well.

## Next steps

This was just a taste of what you can do with Ocuroot, and there's plenty more to explore even
within this repo! Feel free to have a look around to see how everything's configured. You could
also try:

* Deploying a change to the messages service
* Add multiple production environments with different names and ports