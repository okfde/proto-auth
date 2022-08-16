FROM ruby:3.0.4-slim-stretch

RUN apt-get update -qq && apt-get install -y build-essential vim ldap-utils ruby-sqlite3

ENV APP_ROOT /var/www/proto-auth
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD Gemfile* $APP_ROOT/
RUN bundle install
ADD . $APP_ROOT

EXPOSE 3000
EXPOSE 587

CMD ["bundle", "exec", "thin", "start"]
