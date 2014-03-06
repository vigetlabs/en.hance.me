#!/bin/bash

source /etc/profile.d/rbenv.sh

rbenv shell `head -1 .rbenv-version`

bundle exec cap integration deploy:migrations
