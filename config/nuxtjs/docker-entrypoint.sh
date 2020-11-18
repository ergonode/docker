#!/bin/bash

npm install
if [[ ! -f ".env" ]] ; then
    cp .env.dist .env
fi
npm run modules:all
npm rebuild node-sass

if [ "$1" = 'npm' ]  && [ "$2" = 'run' ] && [ "$3" = 'start' ]; then
  if [ -n "${API_BASE_URL}" ] && [ -d ".nuxt" ]; then
      >&2 echo "Setting API_BASE_URL to ${API_BASE_URL}"
      find ".nuxt" -type f -exec  sed  -i "s~http://localhost:8000/api/v1/~${API_BASE_URL}~g" {} +
  else
      npm run build
  fi
fi

echo -e "\e[30;48;5;82mergonode frontend is available at http://localhost:${EXPOSED_NODE_PORT} \e[0m"

exec "$@"
