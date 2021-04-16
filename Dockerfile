FROM ruby:3.0.1-alpine

COPY Gemfile Gemfile.lock /dist/
RUN apk --no-cache update && \
    apk --no-cache add ruby ruby-etc ruby-dev ruby-bigdecimal libc-dev git make gcc g++ libcurl curl-dev curl libstdc++ && \
    gem install bundler && \
    cd /dist/ && \
    bundle install && \
    apk --no-cache del ruby-dev libc-dev git make gcc g++ curl-dev
COPY examples /dist/examples
COPY lib /dist/lib
RUN chmod 0755 /dist/lib/entrypoint.sh
WORKDIR /dist
ENTRYPOINT ["/dist/lib/entrypoint.sh"]
