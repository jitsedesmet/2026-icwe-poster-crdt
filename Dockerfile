FROM ruby:4 AS builder
WORKDIR /app/web

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN bundle exec nanoc compile && \
    google-chrome --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
                  --no-pdf-header-footer --print-to-pdf=output/paper.pdf "file://$(pwd)/output/index.html" && \
    bundle exec nanoc check internal_links mixed_content stale

FROM httpd:2 AS runner

COPY --from=builder /app/web/output /usr/local/apache2/htdocs
