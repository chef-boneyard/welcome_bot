FROM ruby:2.5

WORKDIR /welcome_bot/

COPY . .

RUN bundle install

CMD /welcome_bot/bin/welcome_bot
