FROM ruby:2.7.5-alpine3.13

ARG RAILS_ENV=production
ARG BUNDLER_VERSION=2.4.22
ARG BUNDLE_GEMS__ENGINEERAI__IO

ENV RAILS_ENV=$RAILS_ENV
ENV APP_VERSION=${TAG}

# Install system dependencies
RUN apk update && apk add --no-cache \
  bash build-base libxml2-dev libxslt-dev postgresql postgresql-dev \
  nodejs vim yarn libc6-compat curl git which wkhtmltopdf \
  ttf-ubuntu-font-family imagemagick ffmpeg

# Set working directory
WORKDIR /app

# Copy Gemfile and lockfile for layer caching
COPY Gemfile Gemfile.lock ./

# ✅ Install bundler
RUN gem install bundler -v "${BUNDLER_VERSION}"

# ✅ Configure Gemfury via .netrc (more reliable than bundle config)
RUN echo "machine gem.fury.io\nlogin engineerai\npassword ${BUNDLE_GEMS__ENGINEERAI__IO}" > ~/.netrc

# ✅ Optional debug output
RUN echo "Using Gemfury token: ${BUNDLE_GEMS__ENGINEERAI__IO:0:5}*****"

# ✅ Install gems
RUN bundle install --jobs 4 --retry 3

# Copy rest of the application
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
