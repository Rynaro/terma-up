# frozen_string_literal: true

require 'faraday'
require 'json'

module ClickupTui
  class Client
    BASE_URL = "https://api.clickup.com/api/v2"
    RATE_LIMIT_PER_MINUTE = 100
    RATE_LIMIT_WINDOW = 60
    
    def initialize(token = nil)
      @token = token || Auth.get_token
      raise Error::MissingToken, "No API token found. Run 'clickup-tui auth' to set up authentication." unless @token
      
      @config = ClickupTui.configuration || Config.new
      @connection = build_connection
      @rate_limiter = RateLimiter.new(@config.rate_limit_per_minute, RATE_LIMIT_WINDOW)
    end
    
    # Workspace operations
    def get_workspaces
      rate_limited_request { get("/team") }
    end
    
    def get_spaces(workspace_id)
      rate_limited_request { get("/team/#{workspace_id}/space") }
    end
    
    def get_folders(space_id)
      rate_limited_request { get("/space/#{space_id}/folder") }
    end
    
    def get_lists(folder_id = nil, space_id = nil)
      if folder_id
        rate_limited_request { get("/folder/#{folder_id}/list") }
      elsif space_id
        rate_limited_request { get("/space/#{space_id}/list") }
      else
        raise ArgumentError, "Either folder_id or space_id must be provided"
      end
    end
    
    def get_tasks(list_id, options = {})
      params = build_task_params(options)
      rate_limited_request { get("/list/#{list_id}/task", params) }
    end
    
    def get_task(task_id)
      rate_limited_request { get("/task/#{task_id}") }
    end
    
    # User info for validation
    def get_user
      rate_limited_request { get("/user") }
    end
    
    private
    
    def build_connection
      Faraday.new(@config.api_base_url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.headers['Authorization'] = @token
        conn.headers['Content-Type'] = 'application/json'
        conn.options.timeout = @config.timeout
        
        # Add request/response logging in development
        if ENV['CLICKUP_TUI_DEBUG']
          conn.response :logger, nil, { headers: true, bodies: true }
        end
        
        # Use Net::HTTP adapter (Ruby standard library, ARM64 compatible)
        conn.adapter :net_http
      end
    end
    
    def rate_limited_request(&block)
      @rate_limiter.check_limit!
      
      response = yield
      handle_response(response)
    rescue Faraday::TimeoutError
      raise Error::APIError, "Request timed out. Please check your connection and try again."
    rescue Faraday::ConnectionFailed
      raise Error::APIError, "Failed to connect to ClickUp API. Please check your internet connection."
    rescue Faraday::Error => e
      handle_faraday_error(e)
    end
    
    def get(path, params = {})
      @connection.get(path, params)
    end
    
    def handle_response(response)
      case response.status
      when 200..299
        # Handle different response structures
        body = response.body
        if body.is_a?(Hash)
          # Some endpoints wrap data in a container
          if body.key?('teams')
            body['teams']
          elsif body.key?('spaces')
            body['spaces']
          elsif body.key?('folders')
            body['folders']
          elsif body.key?('lists')
            body['lists']
          elsif body.key?('tasks')
            body['tasks']
          else
            body
          end
        else
          body
        end
      when 401
        raise Error::AuthenticationError, 
              "Invalid API token. Please check your credentials and run 'clickup-tui auth' to update."
      when 403
        raise Error::PermissionError, 
              "Access forbidden. Your token may not have permission to access this resource."
      when 404
        raise Error::APIError,
              "Resource not found. The item you're looking for may have been deleted or moved."
      when 429
        raise Error::RateLimitError, 
              "Rate limit exceeded. Please wait before making more requests."
      when 500..599
        raise Error::ServerError, 
              "ClickUp server error (#{response.status}). Please try again later."
      else
        raise Error::APIError, 
              "Unexpected response: #{response.status} #{response.body}"
      end
    end
    
    def handle_faraday_error(error)
      case error
      when Faraday::UnauthorizedError
        raise Error::AuthenticationError, "Authentication failed. Please check your API token."
      when Faraday::ForbiddenError
        raise Error::PermissionError, "Access forbidden. Check your token permissions."
      when Faraday::ResourceNotFound
        raise Error::APIError, "Resource not found."
      else
        raise Error::APIError, "Network error: #{error.message}"
      end
    end
    
    def build_task_params(options)
      params = {}
      params[:archived] = false unless options[:include_archived]
      params[:statuses] = Array(options[:statuses]) if options[:statuses]
      params[:assignees] = Array(options[:assignees]) if options[:assignees]
      params[:page] = options[:page] if options[:page]
      params[:include_closed] = options[:include_closed] if options.key?(:include_closed)
      params
    end
  end
  
  class RateLimiter
    def initialize(limit, window_seconds)
      @limit = limit
      @window = window_seconds
      @requests = []
    end
    
    def check_limit!
      now = Time.now
      # Remove requests outside the window
      @requests.reject! { |time| now - time > @window }
      
      if @requests.length >= @limit
        sleep_time = @window - (now - @requests.first)
        if sleep_time > 0
          puts "⏳ Rate limit reached. Waiting #{sleep_time.round(1)}s..."
          sleep(sleep_time)
          @requests.clear
        end
      end
      
      @requests << now
    end
  end
end