# frozen_string_literal: true

require 'json'
require 'fileutils'

module ClickupTui
  class Cache
    CACHE_DIR = File.expand_path('~/.cache/clickup-tui')
    DEFAULT_TTL = 300 # 5 minutes
    
    def initialize(ttl: nil)
      @ttl = ttl || DEFAULT_TTL
      @config = ClickupTui.configuration || Config.new
      ensure_cache_directory
    end
    
    def get(key)
      return nil unless @config.cache_enabled
      
      cache_file = cache_file_path(key)
      return nil unless File.exist?(cache_file)
      
      begin
        cache_data = JSON.parse(File.read(cache_file))
        timestamp = cache_data['timestamp']
        data = cache_data['data']
        
        # Check if cache is still valid
        if Time.now.to_i - timestamp <= (@config.cache_ttl_seconds || @ttl)
          data
        else
          # Cache expired, remove file
          File.delete(cache_file)
          nil
        end
      rescue => e
        # If there's any error reading cache, just return nil
        File.delete(cache_file) if File.exist?(cache_file)
        nil
      end
    end
    
    def set(key, data)
      return unless @config.cache_enabled
      
      cache_file = cache_file_path(key)
      cache_data = {
        'timestamp' => Time.now.to_i,
        'data' => data
      }
      
      begin
        File.write(cache_file, JSON.pretty_generate(cache_data))
      rescue => e
        # If we can't write cache, just continue without caching
        puts "Warning: Failed to write cache: #{e.message}" if ENV['CLICKUP_TUI_DEBUG']
      end
    end
    
    def delete(key)
      cache_file = cache_file_path(key)
      File.delete(cache_file) if File.exist?(cache_file)
    end
    
    def clear
      return unless Dir.exist?(CACHE_DIR)
      
      Dir.glob(File.join(CACHE_DIR, '*.json')).each do |file|
        File.delete(file)
      end
      
      puts "✅ Cache cleared"
    end
    
    def cache_key(endpoint, params = {})
      # Create a consistent cache key from endpoint and parameters
      key_parts = [endpoint]
      key_parts << params.to_s if params.any?
      
      # Use MD5 hash to create a filename-safe key
      require 'digest'
      Digest::MD5.hexdigest(key_parts.join('|'))
    end
    
    private
    
    def cache_file_path(key)
      File.join(CACHE_DIR, "#{key}.json")
    end
    
    def ensure_cache_directory
      FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)
    rescue => e
      # If we can't create cache directory, disable caching
      @config.cache_enabled = false if @config.respond_to?(:cache_enabled=)
    end
  end
end