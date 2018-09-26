# Proto-Auth

web based ldap-interface for Prototypefund

## Config

Copy the `.env.sample` and adjust the values to what you need

```bash
$ cp .env.sample .env
```

## No Docker

Expects Ruby > 2.5.1 and `bundler` (`$ gem install bundler`) installed

Run `$ bundle install` to install dependencies.

Run `$ bundle exec thin start` to start the server.

## Docker

### build

`$ docker build -t proto-auth .`

### run

`$ docker run -d --env-file ./.env  proto-auth:latest`
