[![Build Status](https://travis-ci.org/openheritage/open-plaques-3.svg?branch=master)](https://travis-ci.org/openheritage/open-plaques-3)

# Open Plaques

The website behind [Open Plaques](http://openplaques.org)

## Prerequisites

This project requires:

* Ruby (version as specified in the `Gemfile`)
* Postgres
* Bundler (installable with `gem install bundler`)

## Installation

* Copy `example.env` to `.env` – this file is used for configuring environment variables.
* Add a random value for `SECRET_KEY_BASE` in the `.env` file. You can generate this by running
`bundle exec rake secret` on the command line.
* Copy `database.example.yml` to `database.yml`.
* Create two databases for development and testing, and specify these in the `database.yml` file.
* Run `bundle install` to install Gem dependencies.
* Run `bundle exec rake db:setup` to setup the database.

## Running the site

This should just be a case of running `foreman start` on the command line. The output will tell you which URL
you can view it at. Typically this will be `http://localhost:5000`.

## Keeping the database schema up-to-date

When changes to the database schema are required (which you will be warned about), you can make these
changes by running `bundle exec rake db:migrate`.

## Running the tests

You can run the tests (which check that the code does what we expect it to do) by running `bundle exec rspec`.

If you see `0 failures` then everything is ok.

## Local development database

* Run a backup with 'heroku pg:backups public-url --app open-plaques-beta'
* Get the url 'heroku pg:backups public-url --app open-plaques-beta'
* and download it
* create a new empty database
* restore it into postgres (I use the pgAdmin3 graphical tool)
