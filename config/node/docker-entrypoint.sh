#!/bin/bash

if [ "$1" = 'npm' ] ; then
  npm install
  if [[ ! -f ".env" ]]; then
    cp .env.dist .env
  fi
  echo -e "\e[30;48;5;82mergonode frontend is available at http://localhost:${EXPOSED_NODE_PORT} \e[0m"
fi

exec "$@"