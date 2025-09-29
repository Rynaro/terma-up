# frozen_string_literal: true

module ClickupTui
  module Resources
    class FolderResource < BaseResource
      def get_folders(space_id)
        rate_limited_request { @http_client.get("space/#{space_id}/folder") }
      end
    end
  end
end
