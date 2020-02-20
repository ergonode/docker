# Ergonode production docker


## Build
 
1. You Must copy or clone your backend and frontend  app to the docker directory.

2. Directory structure

   ```        
   docker/
   ├── frontend
   ├── backend
   ```

3. Set your **build** environment variables. You can use for this the .env file.

   ```bash
   COMPOSE_PROJECT_NAME=your-app-name
   CONTAINER_REGISTRY_BASE=your-registry-url/your-app-name
   ```

   And optionally your IMAGE tag,  by default this is already set to latest. 

   ```bash
   IMAGE_TAG=latest
   ```
4. Build with command
   ```bash
   docker-compose  -f docker-compose.deploy.yml  build --parallel
   ```

## Test you images

1. For testing your backend code must have must have correctly configured test tools.
If you have correctly set up your testing tools you can execute the commands: 


   ```bash
   #!/bin/bash

   set -eo pipefail

   function finish {
     docker-compose -f docker-compose.test.yml rm --stop --force
   }
   trap finish EXIT
   docker-compose -f docker-compose.test.yml up -d
   until docker-compose -f docker-compose.test.yml run --rm php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
     sleep 1
   done
   
    docker-compose -f docker-compose.test.yml run --rm php bin/phing test
    docker-compose -f docker-compose.test.yml run --rm nuxtjs npm run test
   ```

2. To test your images on local machine you can use command
 
   ```
   docker-compose -f docker-compose.production.yml  -f docker-compose.postgres.yml up -d
   ```
3. And test your app on port 80 (by default this is set in environment variable $EXPOSED_NGINX_PORT) at http://localhost

# Push images to registry

1. To push your images to your registry you need execute commands. 


```bash
docker login your-registry-url
docker-compose  -f docker-compose.deploy.yml  push
```

## Deploy the stack to the swarm


1. You need login to your swarm server by ssh and following command execute on your docker swarm server.  

2. You need set all environment required variables described in `docker-compose.production.yml` and optionally  in `docker-compose.postgres.yml`.

3. For environmental variables, you can create a file `.env`.

4. Example `.env` file:

   ```bash
     COMPOSE_PROJECT_NAME=your-app-name
     CONTAINER_REGISTRY_BASE=your-registry-url/your-app-name

     ...
   ```
5. Login to your registry (if your registry require this for pulling docker images)

    ```bash
    docker login your-registry-url
    ```
   
6. Create the your stack with `docker stack deploy:`
   ```
    $ env $(cat .env | grep ^[a-zA-Z] | xargs) docker stack deploy --compose-file docker-compose.production.yml --compose-file docker-compose.postgres.yml  ergonode
   
    Creating network ergonode_ergonode
    Creating service ergonode_nuxtjs
    Creating service ergonode_php
    Creating service ergonode_postgres
    Creating service ergonode_nginx
   ```

    If  You have managed PostgreSQL by your provider you can skip option `--compose-file docker-compose.postgres.yml`
      
7. Check that it’s running with `docker stack services ergonode`:  
   ```bash
   $ docker stack services ergonode
   ID                  NAME                MODE                REPLICAS            IMAGE                                            PORTS
   4uwzc0p9hetl        ergonode_nginx      replicated          1/1                 docker.io/ergonode/nginx:latest      *:80->80/tcp
   q1me75mm90pw        ergonode_nuxtjs     replicated          1/1                 docker.io/ergonode/nuxtjs:latest       
   rlgcj8dyj54z        ergonode_postgres   replicated          1/1                 docker.io/ergonode/postgres:latest   
   s4hlonu65i8g        ergonode_php        replicated          1/1                 docker.io/ergonode/php:latest
   ```
   This might take some time if you have a multi-node swarm, as images need to be pulled.
   It may take some time if you have a multi-node, because the images have need to be pulled by swarm nodes.
   
   And you can test your application on port 80 (by default this is set in environment variable $EXPOSED_NGINX_PORT) at http://your-swarm-node-ip.
   
8. If you want to bring down your stack then you can execute `docker stack rm:`
   ```bash
   $ docker stack rm ergonode 
   
   Removing service ergonode_nginx
   Removing service ergonode_nuxtjs
   Removing service ergonode_php
   Removing service ergonode_postgres
   Removing network ergonode_ergonode
  ```     