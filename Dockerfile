
FROM ruby:2.7.6

RUN bundle config --global frozen 1

RUN groupadd rails && useradd --create-home -g rails rails
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y gnupg --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
# RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development test

COPY . /usr/src/app
RUN sed -i '/ActiveSupport::EventedFileUpdateChecker/d' config/environments/development.rb
RUN chown -R rails:rails /usr/src/app

# CVE-2016–3714
COPY imagemagick-policy.xml /etc/ImageMagick-6/policy.xml

USER rails
RUN mkdir -p tmp/pids
RUN gpg --import gpgkeyimport.txt
RUN echo "personal-digest-preferences SHA512 SHA384 SHA256\nno-emit-version" > ~/.gnupg/gpg.conf
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
