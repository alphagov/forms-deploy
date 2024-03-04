ARG ALPINE_VERSION=3.19
ARG RUBY_VERSION=3.2.3
ARG DOCKER_IMAGE_DIGEST=sha256:a709ff05ff5e471ab0f824487d9b5777f36850694981c61d10d29290daad735c

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}@${DOCKER_IMAGE_DIGEST}

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --system

ADD . /app
RUN bundle install --system

EXPOSE 4567

CMD ["ruby", "index.rb"]
