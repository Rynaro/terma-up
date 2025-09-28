# Multi-platform Ruby Dockerfile with ARM64 support
FROM ruby:3.2-alpine AS builder

# Install build dependencies for native gems
RUN apk add --no-cache \
    build-base \
    git \
    linux-headers \
    ncurses-dev

WORKDIR /app

# Copy dependency files
COPY Gemfile Gemfile.lock clickup-tui.gemspec ./
COPY lib/clickup_tui/version.rb ./lib/clickup_tui/

# Install gems (works natively on ARM64)
RUN bundle config --local frozen 1 && \
    bundle install --without development test

# Copy application code
COPY . .

FROM ruby:3.2-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
    ncurses \
    ca-certificates \
    tzdata

WORKDIR /app

# Copy gems from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application
COPY --from=builder /app .

# Create non-root user
RUN adduser -D -s /bin/sh clickup

USER clickup

ENTRYPOINT ["bundle", "exec", "clickup-tui"]