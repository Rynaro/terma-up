# frozen_string_literal: true

module ClickupTui
  module Resources
    class TaskResource < BaseResource
      def get_tasks(list_id, options = {})
        params = build_task_params(options)
        rate_limited_request { @http_client.get("list/#{list_id}/task", params) }
      end

      def get_task(task_id)
        rate_limited_request { @http_client.get("task/#{task_id}") }
      end

      private

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
  end
end
