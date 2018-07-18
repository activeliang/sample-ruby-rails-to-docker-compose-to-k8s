### image for build
FROM ruby:2.5.1-alpine
LABEL maintainer 'Aron Muker <aronmuke@gmail.com>'

ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git bash"
ARG DEV_PACKAGES="libxml2-dev libxslt-dev mysql-dev mariadb-client-libs yaml-dev zlib-dev nodejs yarn imagemagick"
ARG RUBY_PACKAGES="tzdata yaml"

ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT

# install packages
RUN apk update \
 && apk upgrade \
 && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

# install rubygem
COPY Gemfile Gemfile.lock $RAILS_ROOT/
RUN bundle install -j4 --path=vendor/bundle

# install npm
COPY package.json yarn.lock $RAILS_ROOT/
RUN yarn install

# build assets
COPY . $RAILS_ROOT
RUN bundle exec rake assets:precompile

ENV RAILS_ENV=production