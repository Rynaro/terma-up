# frozen_string_literal: true

module ClickupTui
  module Error
    class BaseError < StandardError; end
    
    class MissingToken < BaseError; end
    class InvalidTokenFormat < BaseError; end
    class AuthenticationError < BaseError; end
    class PermissionError < BaseError; end
    class RateLimitError < BaseError; end
    class ServerError < BaseError; end
    class APIError < BaseError; end
    class NavigationError < BaseError; end
    class ConfigurationError < BaseError; end
  end
end