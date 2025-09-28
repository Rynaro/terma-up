# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClickupTui::Config do
  describe '#initialize' do
    it 'loads default configuration' do
      config = ClickupTui::Config.new

      expect(config.api_base_url).to eq('https://api.clickup.com/api/v2')
      expect(config.rate_limit_per_minute).to eq(100)
      expect(config.timeout).to eq(30)
      expect(config.per_page).to eq(15)
      expect(config.cache_enabled).to be true
      expect(config.cache_ttl_seconds).to eq(300)
    end
  end

  describe 'environment variable overrides' do
    around(:each) do |example|
      # Store original values
      original_api_url = ENV['CLICKUP_API_URL']
      original_timeout = ENV['CLICKUP_API_TIMEOUT']
      original_per_page = ENV['CLICKUP_TUI_PER_PAGE']

      example.run

      # Restore original values
      ENV['CLICKUP_API_URL'] = original_api_url
      ENV['CLICKUP_API_TIMEOUT'] = original_timeout
      ENV['CLICKUP_TUI_PER_PAGE'] = original_per_page
    end

    it 'respects API URL override' do
      ENV['CLICKUP_API_URL'] = 'https://custom.api.com/v3'

      config = ClickupTui::Config.new
      expect(config.api_base_url).to eq('https://custom.api.com/v3')
    end

    it 'respects timeout override' do
      ENV['CLICKUP_API_TIMEOUT'] = '60'

      config = ClickupTui::Config.new
      expect(config.timeout).to eq(60)
    end

    it 'respects per_page override' do
      ENV['CLICKUP_TUI_PER_PAGE'] = '25'

      config = ClickupTui::Config.new
      expect(config.per_page).to eq(25)
    end
  end
end
