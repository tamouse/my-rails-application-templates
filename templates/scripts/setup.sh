#!/bin/sh

# Complete setup of new rails app

bundle install --without production
rails generate rspec:install
bundle binstub rspec-core
rake db:create db:migrate
rake default
