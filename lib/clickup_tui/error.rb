# frozen_string_literal: true

module ClickupTui
  module Error
    # Base error class for all ClickUp TUI errors
    class BaseError < StandardError; end

    # Authentication and authorization errors
    class MissingToken < BaseError; end
    class InvalidTokenFormat < BaseError; end
    class AuthenticationError < BaseError; end
    class PermissionError < BaseError; end

    # HTTP and connection errors
    class ConnectionError < BaseError; end
    class NotFoundError < BaseError; end
    class RateLimitError < BaseError; end
    class ServerError < BaseError; end

    # Generic API errors (for unexpected responses)
    class APIError < BaseError; end

    # Application-level errors
    class NavigationError < BaseError; end
    class ConfigurationError < BaseError; end
  end
end
