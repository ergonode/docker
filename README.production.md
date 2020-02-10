# Ergonode production docker


## Build
 
You Must copy your backend and frontend app to docker directory.

### directory structure

```        
docker/
├── frontend
├── backend
```


Next, you will need to set required environment vars and list of this vars you can find in used docker-compose files. 

# 

## Environment variables

Set your **build** environment variables

```bash
export COMPOSE_PROJECT_NAME=your-app-name
export CONTAINER_REGISTRY_BASE=your-registry-url/your-app-name
```

And optionally your IMAGE tag,  by default this is already set to latest. 

```bash
export IMAGE_TAG=latest
```

## Build

build with command
```bash
docker-compose build
```

test your image

# Test you images
```bash

function finish {
  docker-compose  rm --force --stop
}
trap finish EXIT

docker-compose -f docker-compose.test.yml up -d
until docker-compose -f docker-compose.test.yml exec php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
    sleep 1
done
docker-compose -f docker-compose.test.yml run php bin/phing test

```

# Deploy 
 Deploy your docker images with production target

```bash
docker-compose  -f docker-compose.deploy.yml  build
docker login your-registry-url
docker-compose  -f docker-compose.deploy.yml  push
```

# Run  in production
run your docker images in production mode

Set all environment required variables described in `docker-compose.production.yml` and optionally  in `docker-compose.postgres.yml`.

### Pull images
```bash
docker-compose -f docker-compose.production.yml  -f docker-compose.postgres.yml pull
```

And run with 

```bash
docker-compose -f docker-compose.production.yml  up -d
```
Or with optionally with postgres provided by this app.

```bash
docker-compose -f docker-compose.production.yml  -f docker-compose.postgres.yml up -d
```

And if you need special volumes configuration for postgres the you can edit `docker-compose.postgres-volumes.yml` And Start your app with command.

```bash
docker-compose -f docker-compose.production.yml  -f docker-compose.postgres.yml -f docker-compose.postgres-volumes.yml up -d
```


### run your images in swarm mode

set you enviormenet variabls


docker network create 
 docker network create --opt encrypted --driver overlay  --attachable ergonode-demo
 
docker stack deploy --compose-file docker-compose.production.yml --compose-file docker-compose.postgres.yml  ergonode-demo