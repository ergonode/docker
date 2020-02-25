#!/bin/bash

if [ "$APP_ENV" == 'prod' ]; then
    export NODE_ENV=production
fi

if [ "$1" = 'npm' ] ; then
  if [ "$APP_ENV" != 'prod' ]; then
    npm install
  fi

  if [[ ! -f ".env" ]] && [ "$APP_ENV" != 'prod' ]; then
    cp .env.dist .env
  fi

  if [ "$1" = 'npm' ]  && [ "$2" = 'run' ] && [ "$3" = 'start' ]; then
     npm run build
  fi

  echo -e "\e[30;48;5;82mergonode frontend is available at http://localhost:${EXPOSED_NODE_PORT} \e[0m"
fi

exec "$@"