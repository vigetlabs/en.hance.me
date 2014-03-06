#!/bin/bash

export RAILS_ENV=test
export COV=true

source /etc/profile.d/rbenv.sh

rbenv shell `head -1 .rbenv-version`

cp ./config/database.yml.example ./config/database.yml

bundle install
bundle exec rake db:create:all
bundle exec rake db:migrate:reset
bundle exec rake spec:coverage
