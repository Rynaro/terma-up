# frozen_string_literal: true

require 'yaml'

module ClickupTui
  class Config
    DEFAULT_CONFIG_PATH = File.expand_path('~/.config/clickup-tui/config.yml')
    DEFAULT_CONFIG = {
      'api' => {
        'base_url' => 'https://api.clickup.com/api/v2',
        'rate_limit_per_minute' => 100,
        'timeout' => 30
      },
      'ui' => {
        'per_page' => 15,
        'show_loading' => true,
        'markdown_width' => 80
      },
      'cache' => {
        'enabled' => true,
        'ttl_seconds' => 300
      }
    }.freeze

    attr_accessor :api_base_url, :rate_limit_per_minute, :timeout,
                  :per_page, :show_loading, :markdown_width,
                  :cache_enabled, :cache_ttl_seconds

    def initialize
      load_config
    end

    def load_config
      file_config = load_config_file
      env_overrides = load_env_overrides

      # Deep merge configuration
      config = deep_merge(file_config, env_overrides)

      # API settings
      @api_base_url = config.dig('api', 'base_url')
      @rate_limit_per_minute = config.dig('api', 'rate_limit_per_minute')
      @timeout = config.dig('api', 'timeout')

      # UI settings
      @per_page = config.dig('ui', 'per_page')
      @show_loading = config.dig('ui', 'show_loading')
      @markdown_width = config.dig('ui', 'markdown_width')

      # Cache settings
      @cache_enabled = config.dig('cache', 'enabled')
      @cache_ttl_seconds = config.dig('cache', 'ttl_seconds')
    end

    private

    def load_config_file
      if File.exist?(config_file_path)
        loaded_config = YAML.load_file(config_file_path) || {}
        # Merge with defaults to ensure all keys are present
        DEFAULT_CONFIG.merge(loaded_config)
      else
        DEFAULT_CONFIG.dup
      end
    rescue StandardError => e
      puts "Warning: Failed to load config file: #{e.message}"
      DEFAULT_CONFIG.dup
    end

    def config_file_path
      ENV['CLICKUP_TUI_CONFIG'] || DEFAULT_CONFIG_PATH
    end

    def load_env_overrides
      overrides = { 'api' => {}, 'ui' => {}, 'cache' => {} }

      # API overrides
      overrides['api']['base_url'] = ENV['CLICKUP_API_URL'] if ENV['CLICKUP_API_URL']
      overrides['api']['timeout'] = ENV['CLICKUP_API_TIMEOUT'].to_i if ENV['CLICKUP_API_TIMEOUT']

      # UI overrides
      overrides['ui']['per_page'] = ENV['CLICKUP_TUI_PER_PAGE'].to_i if ENV['CLICKUP_TUI_PER_PAGE']

      # Cache overrides
      overrides['cache']['enabled'] = ENV['CLICKUP_TUI_CACHE_ENABLED'] == 'true' if ENV['CLICKUP_TUI_CACHE_ENABLED']

      overrides
    end

    def deep_merge(hash1, hash2)
      result = hash1.dup
      hash2.each do |key, value|
        result[key] = if result[key].is_a?(Hash) && value.is_a?(Hash)
                        deep_merge(result[key], value)
                      else
                        value
                      end
      end
      result
    end
  end
end
