#!/usr/bin/env bash

openssl genrsa -out ../../backend/config/jwt/private.pem -aes256 4096
openssl rsa -pubout -in ../../backend/config/jwt/private.pem -out ../../backend/config/jwt/public.pem

bin/phing build
bin/phing database:fixture