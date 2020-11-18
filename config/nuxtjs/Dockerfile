FROM node:14-alpine

RUN apk add --update --no-cache \
    git  \
    python  \
    make \
    g++ && \
    npm install -g create-nuxt-app

ENV HOST 0.0.0.0
