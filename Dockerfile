FROM ruby:2.7.5-alpine3.13

ARG RAILS_ENV=production
ARG BUNDLER_VERSION=2.4.22

ENV RAILS_ENV="${RAILS_ENV}"
ENV APP_VERSION=${TAG}
ENV BUNDLE_GEM__FURY__IO="token:nvHuX-OXxLY2OpiQkFVfgnYgd4CszdA"

RUN apk update && apk add --no-cache \
 bash build-base libxml2-dev libxslt-dev postgresql postgresql-dev \
 nodejs vim yarn libc6-compat curl git which wkhtmltopdf \
 ttf-ubuntu-font-family imagemagick ffmpeg

RUN mkdir /app
WORKDIR /app

# Copy only Gemfiles first for caching
COPY Gemfile* ./

# Install bundler and private gem access
# --- ADD THIS LINE FOR DEBUGGING ---
RUN gem install bundler -v "${BUNDLER_VERSION}" && \
    echo "DEBUG: Checking BUNDLE_GEM__FURY__IO=${BUNDLE_GEM__FURY__IO}" && \
    bundle install
# --- END OF DEBUGGING LINE ---

# Copy the full app code
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]