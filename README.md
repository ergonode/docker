# Ergonode development docker

This is only a development solution! Do not use it on production environments!

## How the hell should I install it all ?!

At first you must install Docker and Docker Compose (https://docs.docker.com/compose).

Next, you must clone frontend and backend and docs repositories to ergonode directory:

```bash
mkdir ergonode
cd ergonode
git clone git@github.com:ergonode/docker.git
git clone git@github.com:ergonode/frontend.git
git clone git@github.com:ergonode/backend.git
git clone git@github.com:ergonode/docs.git
```

Next, you will need to enter docker directory and copy ``.env.dist``

```bash
cd docker
cp .env.dist .env
```

If you want to test ergonode in multiple directories you need to change in the  `.env` file
COMPOSE_PROJECT_NAME env var to some unique value

Remember to setup correct ports in backend and frontend application.

Now you can start start docker by simple command

```bash
docker-compose up
```

Enjoy :)

## Ok, but what now?

if you want to view frontend panel just type address from below into your browser

```
http://localhost
```

if you want to view backend API doc just type address from below into your browser

```
http://localhost:8001/api/doc
```

If you want to review email messages from application, type address from below into your browser

```
http://localhost:8025
```

If you want to review messages on RabbitMQ, type address from below into your browser

```
http://localhost:15672
```

## What can i do with this creature?

If you want to start ergonode docker

```bash
docker-compose start
```

If you want to stop ergonode docker

```bash
docker-compose stop
```

If you want to enter some container

```bash
docker-compose exec php bash
docker-compose exec postgres bash
docker-compose exec node bash
```

## FAQ

```
Q: What data are stored?
A: For now only database in data folder
```

```
Q: Where can i change PHP settings?
A: In config/php/override.ini file
```

```
Q: What if I have better idea?
A: No problem ! Just tell us about your idea and we will discuse it. Bring lot of beers!
```

```
Q: This is awesome, how can i thank you?
A: No problem. Just send me an email to sebastian.bielawski@strix.net and attach a beer
```

```
Q: This is bullshit, how can i thank you for this crap?
A: No problem. Just send me an email to sebastian.bielawski@strix.net but don't forget attach a beer
```

