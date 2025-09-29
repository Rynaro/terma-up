# frozen_string_literal: true

module ClickupTui
  module Resources
    class WorkspaceResource < BaseResource
      def get_workspaces
        rate_limited_request { @http_client.get('team') }
      end

      def get_user
        rate_limited_request { @http_client.get('user') }
      end
    end
  end
end
