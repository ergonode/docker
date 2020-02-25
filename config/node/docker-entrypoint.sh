#!/bin/bash

if [ "$1" = 'npm' ] ; then
  if [ "$APP_ENV" != 'prod' ]; then
    npm install
  fi

  if [[ ! -f ".env" ]] && [ "$APP_ENV" != 'prod' ]; then
    cp .env.dist .env
  fi

  if [ "$1" = 'npm' ]  && [ "$2" = 'run' ] && [ "$3" = 'start' ]; then

    if [ -n "${API_BASE_URL}" ] && [ -d ".nuxt" ]; then
        >&2 echo "Setting API_BASE_URL to ${API_BASE_URL}"
        find ".nuxt" -type f -exec  sed  -i "s~http://localhost:8000/api/v1/~${API_BASE_URL}~g" {} +
    else
        npm run build
    fi
  fi

  echo -e "\e[30;48;5;82mergonode frontend is available at http://localhost:${EXPOSED_NODE_PORT} \e[0m"
fi

exec "$@"