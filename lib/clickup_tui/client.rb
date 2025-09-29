# frozen_string_literal: true

require_relative 'infrastructure/http_client'
require_relative 'infrastructure/rate_limiter'
require_relative 'resources/base_resource'
require_relative 'resources/workspace_resource'
require_relative 'resources/space_resource'
require_relative 'resources/folder_resource'
require_relative 'resources/list_resource'
require_relative 'resources/task_resource'

module ClickupTui
  class Client
    RATE_LIMIT_PER_MINUTE = 100
    RATE_LIMIT_WINDOW = 60

    attr_reader :workspace_resource, :space_resource, :folder_resource, :list_resource, :task_resource

    def initialize(token = nil)
      @token = token || Auth.get_token
      raise Error::MissingToken, "No API token found. Run 'clickup-tui auth' to set up authentication." unless @token

      @config = ClickupTui.configuration || Config.new
      ClickupTui.configuration = @config unless ClickupTui.configuration

      setup_infrastructure
      setup_resources
    end

    # Workspace operations (delegate to resource)
    def get_workspaces
      @workspace_resource.get_workspaces
    end

    def get_spaces(workspace_id)
      @space_resource.get_spaces(workspace_id)
    end

    def get_folders(space_id)
      @folder_resource.get_folders(space_id)
    end

    def get_lists(folder_id = nil, space_id = nil)
      @list_resource.get_lists(folder_id: folder_id, space_id: space_id)
    end

    def get_tasks(list_id, options = {})
      @task_resource.get_tasks(list_id, options)
    end

    def get_task(task_id)
      @task_resource.get_task(task_id)
    end

    # User info for validation
    def get_user
      @workspace_resource.get_user
    end

    private

    def setup_infrastructure
      @http_client = Infrastructure::HttpClient.new(
        token: @token,
        config: @config
      )

      rate_limit = @config.rate_limit_per_minute || RATE_LIMIT_PER_MINUTE
      @rate_limiter = Infrastructure::RateLimiter.new(rate_limit, RATE_LIMIT_WINDOW)
    end

    def setup_resources
      resource_args = { http_client: @http_client, rate_limiter: @rate_limiter }

      @workspace_resource = Resources::WorkspaceResource.new(**resource_args)
      @space_resource = Resources::SpaceResource.new(**resource_args)
      @folder_resource = Resources::FolderResource.new(**resource_args)
      @list_resource = Resources::ListResource.new(**resource_args)
      @task_resource = Resources::TaskResource.new(**resource_args)
    end
  end
end
