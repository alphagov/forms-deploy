# From https://github.com/nbulaj/ruby-chromedriver
FROM ruby:3.1.1-slim-bullseye

ENV DEBIAN_FRONTEND noninteractive
ENV CHROMIUM_DRIVER_VERSION 107.0.5304.18
ENV CHROME_VERSION 107.0.5304.87-1

# Install dependencies & Chrome
RUN apt-get update && apt-get -y --no-install-recommends install gnupg1 zlib1g-dev liblzma-dev wget xvfb unzip libgconf-2-4 libnss3 nodejs \
 && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -  \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update && apt-get -y --no-install-recommends install google-chrome-stable=$CHROME_VERSION \
 && rm -rf /var/lib/apt/lists/*

# Install Chrome driver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMIUM_DRIVER_VERSION/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/bin/ \
    && rm /tmp/chromedriver.zip \
    && chmod ugo+rx /usr/bin/chromedriver \
    && apt-mark hold google-chrome-stable

# RUN mkdir /app && chown ruby:ruby -R /app

RUN gem install bundler -v 2.3.20

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
