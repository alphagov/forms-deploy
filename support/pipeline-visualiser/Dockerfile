ARG ALPINE_VERSION=3.19
ARG RUBY_VERSION=3.2.3
ARG DOCKER_IMAGE_DIGEST=sha256:a709ff05ff5e471ab0f824487d9b5777f36850694981c61d10d29290daad735c

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}@${DOCKER_IMAGE_DIGEST}

# Install system-level dependnecies early on so they can be cached effectively for subsequent builds
# build-base: needed to install be able to install BigDecimal extension requried by 'activesupport-duration-human_string' gem
# libxml2-dev: needed to be able to install libxml-ruby gem required by 'activesupport-duration-human_string' gem
RUN apk add build-base libxml2-dev

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

ADD . /app
RUN bundle config set --local system true && \
    bundle config set --local without development && \
    bundle install

EXPOSE 4567

CMD ["ruby", "index.rb"]
