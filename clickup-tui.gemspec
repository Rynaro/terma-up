# frozen_string_literal: true

require_relative 'lib/clickup_tui/version'

Gem::Specification.new do |spec|
  spec.name          = 'clickup-tui'
  spec.version       = ClickupTui::VERSION
  spec.authors       = ['TermaUp Team']
  spec.email         = ['team@termaup.dev']

  spec.summary       = 'Terminal User Interface for ClickUp'
  spec.description   = 'A Ruby-based Terminal User Interface (TUI) for ClickUp with multi-platform ARM64/AMD64 support'
  spec.homepage      = 'https://github.com/Rynaro/terma-up'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Rynaro/terma-up'
  spec.metadata['changelog_uri'] = 'https://github.com/Rynaro/terma-up/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = 'bin'
  spec.executables   = ['clickup-tui']
  spec.require_paths = ['lib']

  # Core dependencies
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'tty-cursor', '~> 0.7'
  spec.add_dependency 'tty-markdown', '~> 0.7'
  spec.add_dependency 'tty-progressbar', '~> 0.18'
  spec.add_dependency 'tty-prompt', '~> 0.23'
  spec.add_dependency 'tty-screen', '~> 0.8'
  spec.add_dependency 'tty-spinner', '~> 0.9'
  spec.add_dependency 'tty-table', '~> 0.11'

  # Development dependencies
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.18'
  spec.add_development_dependency 'yard', '~> 0.9'
end
