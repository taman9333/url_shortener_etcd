FROM ruby:2.6-alpine

RUN apk add --no-cache build-base postgresql postgresql-dev libpq

RUN gem install bundler

RUN mkdir /url_shortener

WORKDIR /url_shortener

COPY Gemfile Gemfile

COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["thin", "start"]