#!/bin/sh

echo "---- START ----"
apk update && apk add --no-cache build-base
apk update && apk add --no-cache nodejs
apk update && apk add --no-cache postgresql-dev
bundle install
bin/rails assets:precompile
bin/rails server -p 5000 -e $RAILS_ENV
