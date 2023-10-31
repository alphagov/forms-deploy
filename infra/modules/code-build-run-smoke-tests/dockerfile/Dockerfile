FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20231012.1

RUN set -e

#Install system dependencies
RUN yum update -y
RUN yum -y install wget unzip tar procps openssl openssl-devel git libyaml-devel
RUN yum groupinstall -y -q "Development tools"

#Install google chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
RUN yum -y install ./google-chrome-stable_current_x86_64.rpm
RUN ln -s /usr/bin/google-chrome-stable /usr/bin/chromium

#Install chrome driver
RUN wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/118.0.5993.70/linux64/chromedriver-linux64.zip
RUN unzip chromedriver-linux64.zip
RUN mv chromedriver-linux64/chromedriver /usr/bin/chromedriver

#Install rbenv
ENV RBENV_SRC_DIR="/usr/local/rbenv"
ENV PATH="~/.rbenv/shims:$RBENV_SRC_DIR/bin:$RBENV_SRC_DIR/shims:$PATH"
ENV RUBY_BUILD_SRC_DIR="$RBENV_SRC_DIR/plugins/ruby-build"

RUN git clone https://github.com/rbenv/rbenv.git $RBENV_SRC_DIR
RUN mkdir -p $RBENV_SRC_DIR/plugins
RUN git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_SRC_DIR
RUN sh $RUBY_BUILD_SRC_DIR/install.sh

# Create code build user
RUN useradd -m codebuild
USER codebuild

# Install ruby version
ENV RUBY_VERSION="3.2.2"
RUN rbenv install $RUBY_VERSION
RUN rm -rf /tmp/*
RUN rbenv global $RUBY_VERSION
RUN ruby -v

