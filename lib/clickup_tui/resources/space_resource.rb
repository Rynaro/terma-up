# frozen_string_literal: true

module ClickupTui
  module Resources
    class SpaceResource < BaseResource
      def get_spaces(workspace_id)
        rate_limited_request { @http_client.get("team/#{workspace_id}/space") }
      end
    end
  end
end
