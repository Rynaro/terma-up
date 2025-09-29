# frozen_string_literal: true

require 'faraday'
require 'json'

module ClickupTui
  module Infrastructure
    class HttpClient
      DEFAULT_BASE_URL = 'https://api.clickup.com/api/v2'

      def initialize(token:, config: nil)
        @token = token
        @config = config || ClickupTui.configuration || Config.new
        @connection = build_connection
      end

      def get(path, params = {})
        make_request { @connection.get(path, params) }
      end

      def post(path, body = {})
        make_request { @connection.post(path, body) }
      end

      def put(path, body = {})
        make_request { @connection.put(path, body) }
      end

      def delete(path)
        make_request { @connection.delete(path) }
      end

      private

      def build_connection
        base_url = @config.api_base_url || DEFAULT_BASE_URL

        Faraday.new(base_url) do |conn|
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.headers['Authorization'] = @token
          conn.headers['Content-Type'] = 'application/json'

          # Set timeout with fallback
          timeout_value = @config.respond_to?(:timeout) ? @config.timeout : 30
          conn.options.timeout = timeout_value if timeout_value

          # Add request/response logging in development
          conn.response :logger, nil, { headers: true, bodies: true } if ENV['CLICKUP_TUI_DEBUG']

          # Use Net::HTTP adapter (Ruby standard library, ARM64 compatible)
          conn.adapter :net_http
        end
      end

      def make_request
        response = yield
        handle_response(response)
      rescue Faraday::TimeoutError
        raise Error::ConnectionError, 'Request timed out. Please check your connection and try again.'
      rescue Faraday::ConnectionFailed
        raise Error::ConnectionError, 'Failed to connect to ClickUp API. Please check your internet connection.'
      rescue Faraday::Error => e
        handle_faraday_error(e)
      end

      def handle_response(response)
        case response.status
        when 200..299
          extract_response_data(response.body)
        when 401
          raise Error::AuthenticationError,
                "Invalid API token. Please check your credentials and run 'clickup-tui auth' to update."
        when 403
          raise Error::PermissionError,
                'Access forbidden. Your token may not have permission to access this resource.'
        when 404
          raise Error::NotFoundError,
                "Resource not found. The item you're looking for may have been deleted or moved."
        when 429
          raise Error::RateLimitError,
                'Rate limit exceeded. Please wait before making more requests.'
        when 500..599
          raise Error::ServerError,
                "ClickUp server error (#{response.status}). Please try again later."
        else
          raise Error::APIError,
                "Unexpected response: #{response.status} #{response.body}"
        end
      end

      def extract_response_data(body)
        return body unless body.is_a?(Hash)

        # Handle different response structures - ClickUp wraps data in various containers
        data_key = %w[teams spaces folders lists tasks].find { |key| body.key?(key) }
        data_key ? body[data_key] : body
      end

      def handle_faraday_error(error)
        case error
        when Faraday::UnauthorizedError
          raise Error::AuthenticationError, 'Authentication failed. Please check your API token.'
        when Faraday::ForbiddenError
          raise Error::PermissionError, 'Access forbidden. Check your token permissions.'
        when Faraday::ResourceNotFound
          raise Error::NotFoundError, 'Resource not found.'
        else
          raise Error::ConnectionError, "Network error: #{error.message}"
        end
      end
    end
  end
end
