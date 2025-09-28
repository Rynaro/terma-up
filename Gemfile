# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.0'

# Core dependencies (all ARM64 compatible)
gem 'faraday', '~> 2.0'          # HTTP client
gem 'thor', '~> 1.0'             # CLI framework

# TTY components (using compatible versions)
gem 'tty-cursor', '~> 0.7'       # Cursor manipulation
gem 'tty-markdown', '~> 0.7'     # Markdown rendering
gem 'tty-progressbar', '~> 0.18' # Progress indicators
gem 'tty-prompt', '~> 0.23'      # Interactive prompts
gem 'tty-screen', '~> 0.8'       # Terminal screen info
gem 'tty-spinner', '~> 0.9'      # Loading spinners
gem 'tty-table', '~> 0.11'       # Table formatting

group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.50'        # Code linting
  gem 'vcr', '~> 6.0'             # HTTP interaction recording
  gem 'webmock', '~> 3.18'        # HTTP request stubbing
end

group :development do
  gem 'pry', '~> 0.14'            # Interactive debugging
  gem 'yard', '~> 0.9'            # Documentation
end
