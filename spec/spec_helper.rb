# frozen_string_literal: true

require 'bundler/setup'
require 'clickup_tui'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Clean up test tokens after each test
  config.after(:each) do
    begin
      ClickupTui::Auth.clear_token
    rescue
      # Ignore errors during cleanup
    end
  end
end