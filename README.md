# Proto-Auth

web based ldap-interface for Prototypefund

## No Docker

Copy the `.env.sample` and adjust the values to what you need

```bash
$ cp .env.sample .env
```

Expects Ruby > 2.5.1 and `bundler` (`$ gem install bundler`) installed

Run `$ bundle install` to install dependencies.

Run `$ bundle exec thin start` to start the server.

## Docker

### Build image (if you need to)

Assuming you're in the directory, run

```bash
$ docker build -t proto-auth .
```
### Run

Run container in the background.

``` bash
$ docker run -d -p 3000:3000 proto-auth:latest`
```

This command gives you back the container ID. You need this!

Copy .env.sample from the container to your local file path, edit the values, and copy it back into container (container path is defined in the Dockerfile)

``` bash
$ docker cp containerID:/var/www/proto-auth/.env.sample ./.env
$ vi ./.env
$ docker cp .env containerID:/var/www/proto-auth/.env`
```

Then restart the container (the app only loads .env on start up)
`$ docker restart containerID`

That should be it!
