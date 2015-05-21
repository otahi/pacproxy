FROM ruby:2.1.6
MAINTAINER Hiroshi Ota <otahi.pub@gmail.com>

RUN mkdir -p /opt/pacproxy
RUN mkdir -p /opt/pacproxy/work
WORKDIR /opt/pacproxy

COPY Gemfile ./
RUN bundle install

ADD pacproxy.yml /opt/pacproxy/work/pacproxy.yml
ADD proxy.pac    /opt/pacproxy/work/proxy.pac

EXPOSE 3128

WORKDIR /opt/pacproxy/work
CMD pacproxy -c pacproxy.yml
