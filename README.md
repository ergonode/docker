# Ergonode development docker

This is only a development solution! Do not use it on production environments!

## How the hell should I install it all ?!

At first you must install Docker and Docker Compose (https://docs.docker.com/compose).

Next, you must clone frontend and backend repositories to ergonode directory:

```bash
{path}/ergonode/backend
{path}/ergonode/docker
{path}/ergonode/frontend
```

Next, you will need to enter docker directory and start docker by simple command

```bash
bin/docker on
```

If you use it first time, you will need to install all dependencies. We will help you with that with simple command

```bash
bin/docker install
```

Enjoy :)

## Ok, but what now?

if you want to view frontend panel just type address from below into your browser

```
http://localhost
```

if you want to view backend API doc just type address from below into your browser

```
http://locahost:8001/api/doc
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

If you want to stop ergonode docker

```bash
bin/docker off
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

