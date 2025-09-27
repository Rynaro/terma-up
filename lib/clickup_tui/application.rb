# frozen_string_literal: true

module ClickupTui
  class Application
    attr_reader :config, :client, :navigator, :cache
    
    def initialize
      @config = Config.new
      ClickupTui.configuration = @config
      @cache = Cache.new
    end
    
    def run
      setup_client
      setup_navigator
      @navigator.start
    rescue Error::MissingToken
      Display.show_error("No API token found")
      Display.show_info("Please run 'clickup-tui auth' to set up authentication")
      exit(1)
    rescue Error::AuthenticationError => e
      Display.show_error("Authentication failed: #{e.message}")
      Display.show_info("Please check your API token with 'clickup-tui auth'")
      exit(1)
    rescue => e
      Display.show_error("Application error: #{e.message}")
      puts e.backtrace.join("\n") if ENV['CLICKUP_TUI_DEBUG']
      exit(1)
    end
    
    def setup_authentication(token)
      Auth.store_token(token)
      
      # Test the token only if validation is requested
      if ENV['CLICKUP_TUI_VALIDATE_TOKEN'] == 'true'
        test_client = Client.new(token)
        user_data = test_client.get_user
        Display.show_success("Successfully authenticated as #{user_data['username']}")
      else
        Display.show_success("API token stored successfully")
        Display.show_info("Run 'clickup-tui start' to begin using the application")
      end
    rescue Error::AuthenticationError => e
      Display.show_error("Authentication failed: #{e.message}")
      Auth.clear_token
      raise e
    rescue => e
      Display.show_error("Failed to validate token: #{e.message}")
      # Don't clear token on validation failure - it might be network issues
      Display.show_warning("Token saved but could not be validated. You can try using the application anyway.")
    end
    
    def clear_authentication
      Auth.clear_token
    end
    
    def show_status
      puts
      puts "#{Display.bold('🚀 ClickUp TUI Status')}"
      puts "#{Display.dim('─' * 40)}"
      puts
      
      # Authentication status
      if Auth.token_exists?
        begin
          client = Client.new
          user_data = client.get_user
          puts "#{Display.green('✅ Authentication:')} #{user_data['username']}"
        rescue => e
          puts "#{Display.red('❌ Authentication:')} Token invalid (#{e.message})"
        end
      else
        puts "#{Display.red('❌ Authentication:')} No token found"
      end
      
      # Configuration
      puts "#{Display.blue('ℹ️  Configuration:')}"
      puts "  API URL: #{@config.api_base_url || 'https://api.clickup.com/api/v2'}"
      puts "  Rate Limit: #{@config.rate_limit_per_minute || 100}/min"
      puts "  Cache: #{@config.cache_enabled ? 'Enabled' : 'Disabled'}"
      
      # Cache status
      if @config.cache_enabled
        cache_dir = File.expand_path('~/.cache/clickup-tui')
        cache_files = Dir.glob(File.join(cache_dir, '*.json')).size rescue 0
        puts "  Cache Files: #{cache_files}"
      end
      
      puts
    end
    
    def clear_cache
      @cache.clear
    end
    
    def show_version
      puts "ClickUp TUI v#{VERSION}"
    end
    
    private
    
    def setup_client
      @client = Client.new
    end
    
    def setup_navigator
      @navigator = Navigator.new(@client)
    end
  end
end