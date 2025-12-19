ARG ALPINE_VERSION=3.22
ARG RUBY_VERSION=3.4.8
ARG DOCKER_IMAGE_DIGEST=sha256:c7687b054738956d3e409fbb335ffa711c9b2dab87a57a2f89d9141746b9fdde

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}@${DOCKER_IMAGE_DIGEST}

# Install system-level dependnecies early on so they can be cached effectively for subsequent builds
# build-base: needed to install be able to install BigDecimal extension requried by 'activesupport-duration-human_string' gem
# libxml2-dev: needed to be able to install libxml-ruby gem required by 'activesupport-duration-human_string' gem
# tzdata: needed for setting the correct timezone in the container
RUN apk add build-base libxml2-dev tzdata

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

ADD . /app
RUN bundle config set --local system true && \
    bundle config set --local without development && \
    bundle install

RUN ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

EXPOSE 4567

CMD ["ruby", "index.rb"]
