FROM ruby:2.7

WORKDIR /usr/src/app

RUN gem install bundler -v '~> 2.4.0'

COPY Gemfile Appraisals activerecord-mysql-sql-cache.gemspec /usr/src/app/
COPY gemfiles/ /usr/src/app/gemfiles/
RUN mkdir -p lib/activerecord-mysql-sql-cache
COPY lib/activerecord-mysql-sql-cache/version.rb lib/activerecord-mysql-sql-cache/

RUN bundle install
RUN bundle exec appraisal install

ADD . .
