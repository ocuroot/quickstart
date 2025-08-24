# Ocuroot Quickstart

## Overview

* Deploys a set of interrelated services to local Docker
* Ordinarily you would do a local deployment like this with `docker compose`, but to illustrate a more complete deployment to multiple environments, we'll be deploying each service separately.

## Prerequisites

* Docker installed locally
* Git
* Ocuroot client

## Instructions (work in progress)

### 1. Create environments

```bash
ocuroot release new environments.ocu.star
```

This creates the staging environment

### 2. Release frontend

```bash
ocuroot release new frontend/package.ocu.star
```

Will see a pending input to the staging deployment. The shared network must be deployed.

### 3. Release network and complete frontend deployment

```bash
ocuroot release new network/package.ocu.star
```

You can now complete the frontend deployment.

```bash
ocuroot work any
```

Can now open the frontend at http://localhost:8080

### 4. Release backend services

```bash
ocuroot release new time-service/package.ocu.star
```

```bash
ocuroot release new weather-service/package.ocu.star
```

```bash
ocuroot release new message-service/package.ocu.star
```

### 5. Make a change to the message

TODO

### 6. Add a production environment

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

```bash
ocuroot release new environments.ocu.star
```

Deploy all services to production:

```bash
ocuroot work any
ocuroot work any
```

The second run is needed to handle the dependency between `frontend` and `network`.

# 7. Delete environments

Run `docker ps -f name=^quickstart-` to see all the currently running containers.

```bash
ocuroot state delete +/environments/production
ocuroot work any
docker ps -f name=^quickstart-
```

Repeat for the staging environment, see if you can adapt the above.
