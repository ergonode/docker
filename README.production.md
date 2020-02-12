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
docker-compose  -f docker-compose.deploy.yml  build --parallel
```

test your image

# Test you images
```bash

function finish {
    docker-compose -f docker-compose.test.yml rm --stop --force
}
trap finish EXIT

docker-compose -f docker-compose.test.yml up -d
until docker-compose -f docker-compose.test.yml run php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
    sleep 1
done
docker-compose -f docker-compose.test.yml run php bin/phing test

```

# Deploy 
 Deploy your docker images with production target

```bash
docker login your-registry-url
docker-compose  -f docker-compose.deploy.yml  push
```

# Run  in production
run your docker images in production mode

Set all environment required variables described in `docker-compose.production.yml` and optionally  in `docker-compose.postgres.yml`.
You can use for this the `.env` file.

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

### run your images in swarm mode

Set all environment required variables described in `docker-compose.production.yml` and optionally  in `docker-compose.postgres.yml`.
You can use for this the `.env` file.

```
docker stack deploy --compose-file docker-compose.production.yml --compose-file docker-compose.postgres.yml  ergonode
```
