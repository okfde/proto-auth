# Proto-Auth

web based ldap-interface for Prototypefund

## No Docker

### Config

The app reads config values directly  from the environment as this is easier to configure with docker compose.

You can either export all variables in your shell directly or use the .env to source from there. Whatever floats your boat.

Copy the `.env.sample` and adjust the values to what you need.

```bash
$ cp .env.sample .env
```
and then `$ source .env`.

Now your variables are in the environment and the app can read them.

### Running

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

#### Config

The app expects to read config variables in the environment.

You can either set them, for example, in a `docker-compose.yml` (if that is your setup) or by running the same config steps as described in the No docker section in your container.

Alternatively, you can use the `-e VAR=VALUE` flag when running `$ docker run` (see next section) to directly insert the env vars that you need.

#### Run run

Run container in the background.

``` bash
$ docker run -d -p 3000:3000 proto-auth:latest`
```

That should be it!
