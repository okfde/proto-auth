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

### Build

Assuming you're in the directory, run

`$ docker build -t proto-auth .`

### Run

Run container in the background.
`$ docker run -d proto-auth:latest`

This command gives you back the container ID. You need this!

Copy .env file into container (path is defined in the Dockerfile)
`$ docker cp .env containerID:/var/www/proto-auth/.env`

Then restart the container (the app only loads .env on start up)
`$ docker restart containerID`

That should be it!
