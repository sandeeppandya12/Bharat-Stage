FROM ruby:2.7.5-alpine3.13

ARG RAILS_ENV=production
ARG BUNDLER_VERSION=2.4.22

ENV RAILS_ENV=$RAILS_ENV
ENV APP_VERSION=${TAG}

# ✅ Add the private gem token early
ENV BUNDLE_GEM__FURY__IO="nvHuX-OXxLY2OpiQkFVfgnYgd4CszdA"

# Install system dependencies
RUN apk update && apk add --no-cache \
  bash build-base libxml2-dev libxslt-dev postgresql postgresql-dev \
  nodejs vim yarn libc6-compat curl git which wkhtmltopdf \
  ttf-ubuntu-font-family imagemagick ffmpeg

# Set app dir
WORKDIR /app

# Copy only Gemfiles first to cache bundle layer
COPY Gemfile Gemfile.lock ./

# ✅ Configure bundler with token & install gems
RUN gem install bundler -v "${BUNDLER_VERSION}" && \
    bundle config set --global BUNDLE_GEM__FURY__IO "$BUNDLE_GEM__FURY__IO" && \
    bundle install --jobs 4 --retry 3

# Copy rest of the app
COPY . .

# Expose port
EXPOSE 3000

# ✅ Ensure token is available at runtime too
ENV BUNDLE_GEM__FURY__IO="nvHuX-OXxLY2OpiQkFVfgnYgd4CszdA"

# ✅ Explicitly reconfigure bundler in runtime
RUN bundle config set --global BUNDLE_GEM__FURY__IO "$BUNDLE_GEM__FURY__IO"

# Start app
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
