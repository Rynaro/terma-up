# frozen_string_literal: true

module ClickupTui
  module Resources
    class ListResource < BaseResource
      def get_lists(folder_id: nil, space_id: nil)
        if folder_id
          rate_limited_request { @http_client.get("folder/#{folder_id}/list") }
        elsif space_id
          rate_limited_request { @http_client.get("space/#{space_id}/list") }
        else
          raise ArgumentError, 'Either folder_id or space_id must be provided'
        end
      end
    end
  end
end
