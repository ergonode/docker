# Ergonode Docker

## Ergonode Docker uses the following services

 - NGINX 1.17
 - Nodejs 14
 - PHP 7.4
 - PostgreSQL 9.6
 - RabbitMQ 3.8
 
## Containers

### PHP

Container with PHP and Supervisor. Supervisor handle background workers and PHP FPM.

## Development use

### Installation

At first you must install Docker and Docker Compose (https://docs.docker.com/compose).

Next, you must clone frontend, backend and docs repositories to ergonode directory:

```shell script
git clone git@github.com:ergonode/docker.git ergonode
cd ergonode
git clone git@github.com:ergonode/frontend.git
git clone git@github.com:ergonode/backend.git
```

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
docker-compose exec nuxtjs sh
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

## FAQ

##### What data are stored?
For now only database in `data` folder.

#### How to cleanup database?
Remove directory `data/.postgres`. Database will be recreated without data.

##### Where can I change PHP settings?
Add new `ini` file in `config/php/conf.d` directory. If you want to set only for you settings, but without 
commiting it, create configuration file with `custom-` prefix. It will be ignored in GIT.

##### Where can I change Nginx settings?
Add new `conf` file in `config/nginx/conf.d` directory. If you want to set only for you settings, but without 
commiting it, create configuration file with `custom-` prefix. It will be ignored in GIT.

##### How can I add new Supervisor process?
Add new `conf` file in `config/php/supervisor/conf.d` directory. If you want to create custom process, but without 
commiting it, create process file with `custom-` prefix. It will be ignored in GIT.

##### I have error 413 – Request Entity Too Large
You need increase in the nginx `client_max_body_size` and in PHP `upload_max_size`.
