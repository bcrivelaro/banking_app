FROM ruby:3.1.2-alpine
LABEL maintainer="bcrivelaro"

RUN apk --update add build-base nodejs yarn postgresql-client postgresql-dev \
  tzdata bash less && rm -rf /var/cache/apk/

ENV APP_HOME /banking_app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install gems
COPY Gemfile Gemfile.lock $APP_HOME/

RUN gem install bundler:2.3.13
RUN bundle install

COPY . $APP_HOME

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
