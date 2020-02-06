# Ergonode production docker


## Build with docker-compose
 
You Must copy your  backend and frontend app to docker directory:


Next, you will need to set required environment vars and list of this vars you can find in used docker-compose files. 

# 

# build

set your environment variables
```bash
export COMPOSE_PROJECT_NAME=your-app-name
export CONTAINER_REGISTRY_BASE=your-registry-url/your-app-name
```

* build
```bash
docker-compose build
```

test your image

# test
```bash

function finish {
  docker-compose  rm --force --stop
}
trap finish EXIT

docker-compose  -f docker-compose.test.yml up -d
docker-compose  -f docker-compose.test.yml exec php bin/phing test

```

# Deploy
 Deploy your docker images with production target

```bash
docker-compose  -f docker-compose.deploy.yml  build
docker login your-registry-url
docker-compose  -f docker-compose.deploy.yml  push
```

# run  in production
run your docker images in production
```bash
docker-compose  -f docker-compose.production.yml  up -d
```

