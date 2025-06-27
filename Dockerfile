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

# ✅ Install bundler and configure access to private Gemfury gems
RUN gem install bundler -v "${BUNDLER_VERSION}" && \
    bundle config https://gem.fury.io/engineerai/ "$BUNDLE_GEMS__ENGINEERAI__IO" && \
    bundle install --jobs 4 --retry 3

# Copy the rest of the app
COPY . .

# Expose Rails port
EXPOSE 3000

# ✅ Reconfigure bundler at runtime for safety
ENV BUNDLE_GEMS__ENGINEERAI__IO="nvHuX-OXxLY2OpiQkFVfgnYgd4CszdA"

RUN bundle config https://gem.fury.io/engineerai/ "$BUNDLE_GEMS__ENGINEERAI__IO"

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
