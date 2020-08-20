# Ergonode production docker testing on  swarm installed on your localhost


## Preparing the local environment for testing

### Enable Swarm mode

1. You Must enable swarm mode  with command   `docker swarm init`:
   ```
    $ docker swarm init
    Swarm initialized: current node (i4imqmykpz6a6o9amevr491v4) is now a manager.
    
    To add a worker to this swarm, run the following command:
    
        docker swarm join --token SWMTKN-1-5gw46owitfxgvgsbdb19a3cz0ox5ulu07tf7ga1zrto6ouuxrc-a2ulaio3v9rnqqbtxwff2tunj 192.168.99.200:2377
    
    To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

   ```
   In some cases it will be necessary to execute command `docker swarm init --advertise-addr <MANAGER-IP>`
   
   More documentation about enabling swarm mode you can find in https://docs.docker.com/engine/swarm/swarm-mode/


### Set up a Docker registry🔗

For testing you need setup local registry.

1. Start the registry as a service on your swarm:

   ```
   $ docker service create --name registry --publish published=5000,target=5000 registry:2
   5vfwyy0etx9pvb1tcns1qtrl8
   overall progress: 1 out of 1 tasks 
   1/1: running   [==================================================>] 
   verify: Service converged
   ``` 
2. Check its status with `docker service ls`:   

   ```
   $ docker service ls
   ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
   5vfwyy0etx9p        registry            replicated          1/1                 registry:2          *:5000->5000/tcp
   ``` 
3. Check that it’s working with `curl`:
   ```
   $ curl http://localhost:5000/v2/
   
   {}
   ```
   
### Build your production code

1. You Must copy or clone your **production** backend and frontend  app to the docker directory.

2. Directory structure

   ```        
   docker/
   ├── frontend
   ├── backend
   ```
3. Set your **build** environment variables. You can use for this the .env file.

   ```bash
   COMPOSE_PROJECT_NAME=ergonode
   CONTAINER_REGISTRY_BASE=localhost:5000/ergonode
   ```

4. Build with command
   ```bash
   docker-compose  -f docker-compose.deploy.yml  build
   ```
   
   or faster build with enabled BuildKit
   ```
   COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose  -f docker-compose.deploy.yml  build
   ```

### Push images to  local registry

1. To push your images to your registry you need execute command. 

   ```bash
   $ docker-compose  -f docker-compose.deploy.yml  push
   Pushing php (localhost:5000/ergonode/php:latest)...
   The push refers to repository [localhost:5000/ergonode/php]
   9dcb7c3cba06: Pushed
   317220a89f7a: Pushed
   8869b7f8d14b: Pushed
   0b5d19df65c0: Pushed
   67aa39707573: Pushed
   8f0e5fed38ca: Pushed
   9868b4b7e471: Pushed
   3e5a91435251: Pushed
   de4d41a476fa: Pushed
   cf44941de815: Pushed
   bb9023598f8e: Pushed
   80b84485e3db: Pushed
   09910eb25821: Pushed
   93bcee3daaff: Pushed
   c1f1b3bb785a: Pushed
   1769ec9d9fbb: Pushed
   2be2bea30da4: Pushed
   35c5254fa70a: Pushed
   98075e80af84: Pushed
   e02653067cbc: Pushed
   6f376367414e: Pushed
   546d72961a9b: Pushed
   a284cca01749: Pushed
   0f17bf26d50f: Pushed
   a08a6a32d21a: Pushed
   9ca12a39140e: Pushed
   0078526f623d: Pushed
   ba661e61e5ca: Pushed
   ee40c7334a95: Pushed
   beee9f30bc1f: Pushed
   latest: digest: sha256:571240eceee46a9ddec431c3a05181e286382925948030585562d03c61b8e4ac size: 6593
   Pushing nuxtjs (localhost:5000/ergonode/nuxtjs:latest)...
   The push refers to repository [localhost:5000/ergonode/nuxtjs]
   d4bf0d1f3bae: Pushed
   5f70bf18a086: Pushed
   4511ef4fad3d: Pushed
   111e3208ee56: Pushed
   fe5324d0691a: Pushed
   f2569cae1768: Pushed
   352920ec1073: Pushed
   662f8f5a2b7a: Pushed
   00210cd15c5c: Pushed
   ffa1cdbe8bf7: Pushed
   f1b5933fe4b5: Pushed
   latest: digest: sha256:a624e2ff6f8fd1684a377a82c0e6258174684479f5da37fb2d6686997367bff0 size: 2827
   Pushing nginx (localhost:5000/ergonode/nginx:latest)...
   The push refers to repository [localhost:5000/ergonode/nginx]
   15f7b07e2eb1: Pushed
   c4a41daeabbf: Pushed
   6a7bac1cc4a5: Pushed
   0f91bfd1b7b4: Pushed
   bc4f27e27c4c: Pushed
   03e7b7ac5f4c: Pushed
   ca38b6f1110c: Pushed
   6f23cf4d16de: Pushed
   531743b7098c: Pushed
   latest: digest: sha256:96cb5a1245ac7792df763bebe1c261272a4b4e4c7f09d2fd5d066eef20899202 size: 2405
   Pushing postgres (localhost:5000/ergonode/postgres:latest)...
   The push refers to repository [localhost:5000/ergonode/postgres]
   ad721fbf05ac: Pushed
   20b113d053ff: Pushed
   a283fe349755: Pushed
   004c5c491659: Pushed
   2084a1a5fdaa: Pushed
   36589f5f7745: Pushed
   554b8a481572: Pushed
   ad31bd535054: Pushed
   2d9f8a4bb985: Pushed
   c1fe1c22cb47: Pushed
   34ba88304670: Pushed
   a55a08db54f9: Pushed
   beee9f30bc1f: Mounted from ergonode/php
   latest: digest: sha256:51d61dc5992c093fbb69a960376bc20b327fddf807b7876b56e6652c61c2198a size: 3020
   Pushing haproxy (localhost:5000/ergonode/haproxy:latest)...
   The push refers to repository [localhost:5000/ergonode/haproxy]
   1dd6602aeaba: Pushed
   1d7bfabed83a: Pushed
   26ab55d789a8: Pushed
   065b7480de97: Pushed
   beee9f30bc1f: Mounted from ergonode/postgres
   latest: digest: sha256:be0c4ef6d6ff88ae660f1e4def955fe70166bb9e57d224b1dda54a0d9cc5549d size: 1363
   Pushing rabbitmq (localhost:5000/ergonode/rabbitmq:latest)...
   The push refers to repository [localhost:5000/ergonode/rabbitmq]
   84a43432a8f4: Pushed
   14424cfa9842: Pushed
   757705f5325b: Pushed
   0929bd357320: Pushed
   77a02e0abffa: Pushed
   ef81076db681: Pushed
   3a77603d9a2e: Pushed
   55285c124aa2: Pushed
   5f445fdd2cbe: Pushed
   b533ec746365: Pushed
   3af4411af099: Pushed
   ea443b32be83: Pushed
   beee9f30bc1f: Mounted from ergonode/haproxy
   latest: digest: sha256:81e6b3204ac1688a2476b91227d4a9dad61f835b5794a59b38a2e950f735d5ce size: 3038
   ```
### Deploy the stack to the swarm


1. You need set all environment required variables described in `docker-compose.production.yml` and  in `docker-compose.postgres.yml`.
2. And also you need create secrets required in `docker-compose.production.yml` and  in `docker-compose.postgres.yml`.

   For each secret please enter your secret and press CTRL+D 
   ```
   $ docker secret create ergonode-postgres-passwd -    
   ```
   ```
   $ docker secret create ergonode-user-passwd -    
   ```

3. For environmental variables, you can create a file `.env`.

4. Create the your stack with `docker stack deploy:`
   ```
    $ env $(cat .env | grep ^[a-zA-Z] | xargs) docker stack deploy --compose-file docker-compose.production.yml --compose-file docker-compose.postgres.yml  ergonode
   
    Creating network ergonode_ergonode
    Creating service ergonode_php-messenger-event
    Creating service ergonode_php-messenger-export
    Creating service ergonode_rabbitmq-02
    Creating service ergonode_php-messenger-core
    Creating service ergonode_php
    Creating service ergonode_nginx
    Creating service ergonode_php-messenger-channel
    Creating service ergonode_php-messenger-import
    Creating service ergonode_postgres
    Creating service ergonode_rabbitmq-01
    Creating service ergonode_consul
    Creating service ergonode_nuxtjs
    Creating service ergonode_php-messenger-segment
    Creating service ergonode_rabbitmq-03
    Creating service ergonode_haproxy
   ```
      
5. Check that it’s running with `docker stack services ergonode`:  

   ```bash
   $ docker stack services ergonode
   ID                  NAME                             MODE                REPLICAS            IMAGE                                     PORTS
   3etmk5oaiq1h        ergonode_php-messenger-channel   replicated          1/1                 localhost:5000/ergonode/php:latest        
   69uby4hcw9ar        ergonode_php-messenger-segment   replicated          1/1                 localhost:5000/ergonode/php:latest        
   8qtlwf3u3wli        ergonode_rabbitmq-01             global              1/1                 localhost:5000/ergonode/rabbitmq:latest   
   bvel8mli4ymd        ergonode_rabbitmq-03             global              1/1                 localhost:5000/ergonode/rabbitmq:latest   
   cxtlqpulnjjl        ergonode_php-messenger-core      replicated          1/1                 localhost:5000/ergonode/php:latest        
   g0daudkr5v3c        ergonode_php-messenger-export    replicated          1/1                 localhost:5000/ergonode/php:latest        
   h9uc5g0kqffy        ergonode_postgres                global              1/1                 localhost:5000/ergonode/postgres:latest   
   i0u876bxsyul        ergonode_nuxtjs                  replicated          1/1                 localhost:5000/ergonode/nuxtjs:latest     
   jvz19jpgzzb9        ergonode_nginx                   replicated          1/1                 localhost:5000/ergonode/nginx:latest      *:80->80/tcp
   ls2wvroa777r        ergonode_php-messenger-import    replicated          1/1                 localhost:5000/ergonode/php:latest        
   n3ukz3z6tm30        ergonode_consul                  replicated          1/1                 consul:1.7                                
   of4toxprxoaf        ergonode_rabbitmq-02             global              1/1                 localhost:5000/ergonode/rabbitmq:latest   
   rlnxa9vsuedh        ergonode_php                     replicated          1/1                 localhost:5000/ergonode/php:latest        
   skcutkkb5fza        ergonode_haproxy                 global              1/1                 localhost:5000/ergonode/haproxy:latest    *:15672->15672/tcp
   t3sjf8ibv5yv        ergonode_php-messenger-event     replicated          1/1                 localhost:5000/ergonode/php:latest 
   ```
   This might take some time if you have a multi-node swarm, as images need to be pulled.
   It may take some time if you have a multi-node, because the images have need to be pulled by swarm nodes.
   
   And you can test your application on port 80 (by default this is set in environment variable $EXPOSED_NGINX_PORT) at http://your-swarm-node-ip.

6. To check your service logs you can do this with `docker service logs ergonode_service_name` 
   ```bash
   $ docker   service logs -f ergonode_nginx
   ergonode_nginx.1.z8ohiml3lj9l@swarm    | 127.0.0.1 - - [25/Feb/2020:09:59:49 +0000] "GET /api/doc HTTP/1.1" 200 98347 "-" "curl/7.66.0" "-"
   ``` 
7. To troubleshoot why some services does not up . You can find your service container with command:
    ```bash
    $ docker ps
    ```
    
    This example display container id for php service
    
    ```bash
    $ docker ps  -f name=ergonode_php.1
    CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS                    PORTS               NAMES
    a81d054a6473        localhost:5000/ergonode/php:latest   "docker-entrypoint p…"   10 minutes ago      Up 10 minutes (healthy)   9000/tcp            ergonode_php.1.fd63lm163x7wudnob7xrju91h
    ```
    
    And to display logs you can execute
    ```
    $ docker logs a81d054a6473
    Linking /usr/local/etc/php/php.ini-production > /usr/local/etc/php/php.ini
    Verified OK
    Setting file permissions...
    Waiting for db to be ready...
                                                                        
                        Doctrine Database Migrations                    
                                                                        
    
    No migrations to execute.
    app initialization finished
    [01-Apr-2020 18:30:05] NOTICE: fpm is running, pid 1
    [01-Apr-2020 18:30:05] NOTICE: ready to handle connections
    ```

8. If you want to bring down your stack then you can execute `docker stack rm:`
   ```bash
   $ docker stack rm ergonode 
   
   Removing service ergonode_consul
   Removing service ergonode_haproxy
   Removing service ergonode_nginx
   Removing service ergonode_nuxtjs
   Removing service ergonode_php
   Removing service ergonode_php-messenger-channel
   Removing service ergonode_php-messenger-core
   Removing service ergonode_php-messenger-event
   Removing service ergonode_php-messenger-export
   Removing service ergonode_php-messenger-import
   Removing service ergonode_php-messenger-segment
   Removing service ergonode_postgres
   Removing service ergonode_rabbitmq-01
   Removing service ergonode_rabbitmq-02
   Removing service ergonode_rabbitmq-03
   Removing network ergonode_ergonode
   ```
 
   And you can optionally prune ergonode volumes
    
   ```
   $ docker volume prune --filter label=com.docker.stack.namespace=ergonode
   WARNING! This will remove all local volumes not used by at least one container.
   Are you sure you want to continue? [y/N] y
   Deleted Volumes:
   ergonode_multimedia
   ergonode_avatar
   ergonode_import
   ergonode_jwt
   ergonode_ergonode-postgres-data
   ergonode_rabbitmq-01
   ergonode_rabbitmq-02
   ergonode_rabbitmq-03
   
   Total reclaimed space: 1.086GB
   ```
