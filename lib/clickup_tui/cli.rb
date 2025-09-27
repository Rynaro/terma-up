# frozen_string_literal: true

require 'thor'

module ClickupTui
  class CLI < Thor
    desc "start", "Start the ClickUp TUI interface"
    def start
      application = Application.new
      application.run
    end
    
    desc "auth [TOKEN]", "Set up ClickUp API authentication"
    option :token, type: :string, desc: "ClickUp API token (pk_*)"
    def auth(token = nil)
      token ||= options[:token]
      
      if token
        # Token provided as argument or option
        setup_token(token)
      else
        # Interactive token setup
        interactive_auth
      end
    end
    
    desc "status", "Show authentication and configuration status"
    def status
      application = Application.new
      application.show_status
    end
    
    desc "clear-auth", "Clear stored authentication token"
    def clear_auth
      application = Application.new
      application.clear_authentication
      Display.show_success("Authentication cleared")
    end
    
    desc "clear-cache", "Clear cached API responses"
    def clear_cache
      application = Application.new
      application.clear_cache
    end
    
    desc "version", "Show version information"
    def version
      application = Application.new
      application.show_version
    end
    
    # Default action (when no command is given)
    def self.default_task
      "start"
    end
    
    private
    
    def setup_token(token)
      application = Application.new
      
      puts "Setting up ClickUp API authentication..."
      puts
      
      begin
        application.setup_authentication(token)
      rescue => e
        Display.show_error("Setup failed: #{e.message}")
        exit(1)
      end
    end
    
    def interactive_auth
      puts
      puts "#{Display.bold('🔐 ClickUp API Authentication Setup')}"
      puts "#{Display.dim('─' * 50)}"
      puts
      puts "To use ClickUp TUI, you need a personal API token."
      puts
      puts "#{Display.bold('How to get your API token:')}"
      puts "1. Go to #{Display.cyan('https://app.clickup.com/settings/apps')}"
      puts "2. Click '#{Display.bold('+ Generate')}' under 'Personal API Token'"
      puts "3. Copy the token (it starts with 'pk_')"
      puts
      
      require 'tty-prompt'
      prompt = TTY::Prompt.new
      
      token = prompt.mask("Enter your ClickUp API token:", required: true) do |q|
        q.validate(/\Apk_/, "Token must start with 'pk_'")
      end
      
      setup_token(token)
    end
  end
end