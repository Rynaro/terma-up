# frozen_string_literal: true

module ClickupTui
  module Infrastructure
    class RateLimiter
      DEFAULT_RATE_LIMIT_PER_MINUTE = 100
      DEFAULT_RATE_LIMIT_WINDOW = 60

      def initialize(limit = nil, window_seconds = nil)
        @limit = limit || DEFAULT_RATE_LIMIT_PER_MINUTE
        @window = window_seconds || DEFAULT_RATE_LIMIT_WINDOW
        @requests = []
      end

      def check_limit!
        now = Time.now
        # Remove requests outside the window
        @requests.reject! { |time| now - time > @window }

        if @requests.length >= @limit
          sleep_time = @window - (now - @requests.first)
          if sleep_time.positive?
            puts "⏳ Rate limit reached. Waiting #{sleep_time.round(1)}s..."
            sleep(sleep_time)
            @requests.clear
          end
        end

        @requests << now
      end

      def within_limit(&block)
        check_limit!
        yield
      end
    end
  end
end
