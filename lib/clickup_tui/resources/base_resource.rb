# frozen_string_literal: true

module ClickupTui
  module Resources
    class BaseResource
      def initialize(http_client:, rate_limiter:)
        @http_client = http_client
        @rate_limiter = rate_limiter
      end

      private

      def rate_limited_request(&block)
        @rate_limiter.within_limit(&block)
      end
    end
  end
end
