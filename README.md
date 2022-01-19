# Ergonode Docker

## Ergonode Docker uses the following services

 - PostgreSQL 10
 - PHP 7.4
 - NGINX 1.17
 - Docsify 4
 - Nodejs 12.6 
 - RabbitMQ 3.8

## Development use

### Installation

At first you must install Docker and Docker Compose (https://docs.docker.com/compose).

Next, you must clone frontend, backend and docs repositories to ergonode directory:

```shell script
git clone git@github.com:ergonode/docker.git ergonode
cd ergonode
git clone git@github.com:ergonode/frontend.git
git clone git@github.com:ergonode/backend.git
git clone git@github.com:ergonode/docs.git
```

If you want to test ergonode in multiple directories you need to create the  `.env` file and set
`COMPOSE_PROJECT_NAME` env var to some unique value.

If you want change any environment variable you can optionally change this in the `.env` file. 
And all environment variables used by our docker you can find in the `docker-compose.yml` files.

Now you can start docker by simple command

```shell script
docker-compose up
```

### Backend setup

List of changes that must be made in `ergonode/backend` configuration.

#### Messenger DSN

Messenger DSN addresses must be changed to `amqp://ergonode:ergonode@rabbit:5672` in your `.env.local` file.

For example:
```
MESSENGER_TRANSPORT_DSN=amqp://ergonode:ergonode@rabbitmq:5672/%2f/messages
```

#### Mailer DSN

Mailer DSN address must be changed to `smtp://mailhog:1025` in your `.env.local` file.

### Database filling

Now you can fill database with basic data by using command
```shell script
docker-compose exec php bin/phing database:fixture
```

Or fill database with development data with command
```shell script
docker-compose exec php bin/phing database:fixture:dev
```

### Shell side usage

To run all tests execute 
```shell script
docker-compose exec php bin/phing test
```

To run symfony console 
```shell script
docker-compose exec php bin/console
```

To add new users you can use command 
```shell script
docker-compose exec php bin/console ergonode:user:create  <email> <first_name> <last_name> <password> <language> [<role>]
```

If you want to enter some container

```shell script
docker-compose exec php bash
docker-compose exec postgres bash
docker-compose exec nuxtjs bash
```

### Browser side usage

If you want to view frontend panel just type address from below into your browser

```
http://localhost
```

And to test app you can login as `test@ergonode.com` with password `abcd1234`

If you want to view backend API doc just type address from below into your browser

```
http://localhost:8000/api/doc
```

If you want to review messages on RabbitMQ, type address from below into your browser

```
http://localhost:15672
```

If you want to see documentation, type address from below into your browser

```
http://localhost:8002
```

## FAQ

##### I have error 413 – Request Entity Too Large
You need increase in the nginx `client_max_body_size` and in php `upload_max_size`.

##### How to increase the nginx client_max_body_size and in php upload max size?
In the .env file please set `NGINX_HTTP_DIRECTIVES` to `client_max_body_size 250m;` or higher value
`NGINX_HTTP_DIRECTIVES="client_max_body_size 250m;`.
Also you can set `PHP_INI_DIRECTIVES` to `upload_max_filesize=250M; post_max_size = 250M;`

##### How to increase php memory limit?
In the `.env` file please set `PHP_INI_DIRECTIVES` to `memory_limit=1024M;` or higher value
```
PHP_INI_DIRECTIVES="memory_limit=1024M;" 
```

##### What data are stored?
For now only database in `data` folder

##### Where can i change PHP settings?
In the environment variable `PHP_INI_DIRECTIVES` each setting must be delimited by `;`

##### Where can i change nginx http settings?
In the environment variable `NGINX_HTTP_DIRECTIVES` each setting must be delimited by `;`

##### What if I have better idea?
No problem ! Just tell us about your idea and we will discuse it. Bring lot of beers!
