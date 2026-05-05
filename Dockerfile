# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=4.0.3

# =============================================================================
# Development stage (for docker-compose)
# =============================================================================
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS dev

WORKDIR /rails

RUN <<-EOF
  set -e
  apt-get update -qq
  apt-get install --no-install-recommends -y build-essential curl git libyaml-dev libpq-dev
  rm -rf /var/lib/apt/lists /var/cache/apt/archives
EOF

COPY Gemfile Gemfile.lock .ruby-version ./
RUN --mount=type=secret,id=bundle_config,target=/root/.bundle/config \
    bundle install -j "$(nproc)"

# =============================================================================
# Production build (for Kamal)
# =============================================================================
# docker build -t lizard .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name lizard lizard

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN <<-EOF
  set -e
  apt-get update -qq
  apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq5
  rm -rf /var/lib/apt/lists /var/cache/apt/archives
  ldconfig -p | grep -q libjemalloc
EOF

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="libjemalloc.so.2"

# Gem cache stage for shared gem caching
FROM base AS gem-cache

ARG TARGETPLATFORM

# Install packages needed to build gems and PostgreSQL client
RUN <<-EOF
  set -e
  apt-get update -qq
  apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config libpq-dev
  rm -rf /var/lib/apt/lists /var/cache/apt/archives
EOF

# Install application gems with cache mount
COPY Gemfile Gemfile.lock .ruby-version ./
RUN --mount=type=cache,id=gems-${TARGETPLATFORM},target=/usr/local/bundle,sharing=locked \
    --mount=type=secret,id=bundle_config,target=/root/.bundle/config \
    <<-EOF
  set -e
  bundle config set --local jobs $(nproc)
  bundle config set --local frozen true
  bundle install
  bundle exec bootsnap precompile --gemfile
  cp -r /usr/local/bundle /tmp/bundle
  rm -rf /tmp/bundle/ruby/*/cache /tmp/bundle/ruby/*/bundler/gems/*/.git
EOF

# Persist gems into layer (cache mounts may be empty on external cache hits)
RUN rm -rf /usr/local/bundle && mv /tmp/bundle /usr/local/bundle

# Throw-away build stage to reduce size of final image
FROM gem-cache AS build

# Copy application code
COPY . .

# Write git revision for runtime version display
ARG GIT_SHA
RUN echo "$GIT_SHA" > REVISION

# Precompile bootsnap and assets without requiring secret RAILS_MASTER_KEY
RUN <<-EOF
  set -e
  bundle exec bootsnap precompile app/ lib/
  SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
EOF

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN <<-EOF
  set -e
  groupadd --system --gid 1000 rails
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
  chown -R rails:rails db log storage tmp
EOF
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
