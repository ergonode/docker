# Ergonode development docker

This is only a development solution! Do not use it on production environments!

## the docker uses the following services

 - PostgreSQL 10
 - PHP 7.4
 - NGINX 1.17
 - Docsify 4
 - Nodejs 12.6 
 - RabbitMQ 3.8
 
## How the hell should I install it all ?!

At first you must install Docker and Docker Compose (https://docs.docker.com/compose).

Next, you must clone frontend and backend and docs repositories to ergonode directory:

```bash
git clone git@github.com:ergonode/docker.git ergonode
cd ergonode
git clone git@github.com:ergonode/frontend.git
git clone git@github.com:ergonode/backend.git
git clone git@github.com:ergonode/docs.git
```


If you want to test ergonode in multiple directories you need to create the  `.env` file and set
COMPOSE_PROJECT_NAME env var to some unique value

Now you can start start docker by simple command

```bash
docker-compose up
```

Now you can fill  app database with basic data by using command
```
docker-compose exec php bin/phing database:fixture
```

Or fill database with development data with command
```
docker-compose exec php bin/phing database:fixture:dev
```

Enjoy :)

## Ok, but what now?


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

## What can i do with this creature?

To run all tests execute 
```
docker-compose exec php bin/phing test
```

To run symfony console 
```
docker-compose exec php bin/console
```

To add new users you can use command 
```
docker-compose exec php bin/console ergonode:user:create  <email> <first_name> <last_name> <password> <language> [<role>]
```

If you want to enter some container

```bash
docker-compose exec php bash
docker-compose exec postgres bash
docker-compose exec nuxtjs bash
```

## FAQ

```
Q: I have error 413 – Request Entity Too Large
A: You need increase in the nginx client_max_body_size and in php upload max size. 
```

```
Q: How to increase the nginx client_max_body_size and in php upload max size?
```

In the .env file please set `NGINX_HTTP_DIRECTIVES` to `client_max_body_size 250m;` or higher value
```
NGINX_HTTP_DIRECTIVES="client_max_body_size 250m;" 
```
Also you can set `PHP_INI_DIRECTIVES` to `upload_max_filesize=250M;\npost_max_size = 250M;`

```
Q: How to increase php memory limit?
```
In the .env file please set `PHP_INI_DIRECTIVES` to `memory_limit=1024M;` or higher value

```
PHP_INI_DIRECTIVES="memory_limit=1024M;" 
```

```
Q: What data are stored?
A: For now only database in data folder
```

```
Q: Where can i change PHP settings?
A: In the environment variable PHP_INI_DIRECTIVES each setting must be delimited by ;
```

```
Q: Where can i change nginx http settings?
A: In the environment variable NGINX_HTTP_DIRECTIVES each setting must be delimited by ;
```

```
Q: What if I have better idea?
A: No problem ! Just tell us about your idea and we will discuse it. Bring lot of beers!
```

```
Q: This is awesome, how can i thank you?
A: No problem. Just send me an email to daniel.marynicz@strix.net and attach a beer
```

```
Q: This is bullshit, how can i thank you for this crap?
A: No problem. Just send me an email to daniel.marynicz@strix.net but don't forget attach a beer
```

