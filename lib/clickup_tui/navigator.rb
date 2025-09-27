# frozen_string_literal: true

require 'tty-prompt'
require 'tty-cursor'
require 'tty-screen'

module ClickupTui
  class Navigator
    attr_reader :client, :current_context, :navigation_stack, :cache
    
    def initialize(client)
      @client = client
      @prompt = TTY::Prompt.new
      @cursor = TTY::Cursor
      @current_context = { type: :workspaces }
      @navigation_stack = []
      @cache = Cache.new
      @config = ClickupTui.configuration || Config.new
    end
    
    def start
      Display.show_welcome
      validate_authentication
      main_navigation_loop
    rescue Interrupt
      Display.show_goodbye
      exit(0)
    rescue Error::AuthenticationError => e
      Display.show_error("Authentication failed: #{e.message}")
      Display.show_info("Please run 'clickup-tui auth' to set up your API token")
      exit(1)
    end
    
    private
    
    def validate_authentication
      Display.show_loading("Validating authentication...") do
        @client.get_user
      end
    rescue Error::AuthenticationError => e
      raise e
    rescue => e
      Display.show_warning("Could not validate authentication: #{e.message}")
      Display.show_info("Continuing anyway...")
    end
    
    def main_navigation_loop
      loop do
        begin
          Display.show_breadcrumb(@navigation_stack, @current_context)
          
          case @current_context[:type]
          when :workspaces
            navigate_workspaces
          when :spaces
            navigate_spaces
          when :folders
            navigate_folders
          when :lists
            navigate_lists
          when :tasks
            navigate_tasks
          when :task_detail
            show_task_detail
          end
        rescue Error::APIError => e
          Display.show_error("API Error: #{e.message}")
          prompt_continue_or_quit
        rescue Error::NavigationError => e
          Display.show_error("Navigation Error: #{e.message}")
          navigate_back
        rescue => e
          Display.show_error("Unexpected error: #{e.message}")
          puts e.backtrace.join("\n") if ENV['CLICKUP_TUI_DEBUG']
          prompt_continue_or_quit
        end
      end
    end
    
    def navigate_workspaces
      workspaces_data = fetch_with_cache("workspaces") { @client.get_workspaces }
      
      if workspaces_data.empty?
        Display.show_error("No workspaces found")
        exit(1)
      end
      
      choices = build_workspace_choices(workspaces_data)
      choices << { name: "🚪 Exit", value: :exit }
      
      selection = @prompt.select("Select a Workspace:", choices, per_page: @config.per_page)
      
      case selection
      when :exit
        exit(0)
      else
        push_context(:spaces, workspace_id: selection[:id], workspace_name: selection[:name])
      end
    end
    
    def navigate_spaces
      spaces_data = fetch_with_cache("spaces_#{@current_context[:workspace_id]}") do
        @client.get_spaces(@current_context[:workspace_id])
      end
      
      choices = build_space_choices(spaces_data)
      add_navigation_choices(choices)
      
      selection = @prompt.select("Select a Space:", choices, per_page: @config.per_page)
      handle_navigation_selection(selection, :folders, :space_id, :space_name)
    end
    
    def navigate_folders
      folders_data = fetch_with_cache("folders_#{@current_context[:space_id]}") do
        @client.get_folders(@current_context[:space_id])
      end
      
      choices = build_folder_choices(folders_data)
      
      # Also get lists directly in space (folderless lists)
      space_lists_data = fetch_with_cache("space_lists_#{@current_context[:space_id]}") do
        @client.get_lists(nil, @current_context[:space_id])
      end
      
      choices += build_list_choices(space_lists_data, prefix: "📋 ")
      
      add_navigation_choices(choices)
      
      selection = @prompt.select("Select a Folder or List:", choices, per_page: @config.per_page)
      
      if selection[:type] == :list
        push_context(:tasks, 
          list_id: selection[:id], 
          list_name: selection[:name])
      else
        handle_navigation_selection(selection, :lists, :folder_id, :folder_name)
      end
    end
    
    def navigate_lists
      lists_data = fetch_with_cache("lists_#{@current_context[:folder_id]}") do
        @client.get_lists(@current_context[:folder_id])
      end
      
      choices = build_list_choices(lists_data)
      add_navigation_choices(choices)
      
      selection = @prompt.select("Select a List:", choices, per_page: @config.per_page)
      handle_navigation_selection(selection, :tasks, :list_id, :list_name)
    end
    
    def navigate_tasks
      Display.show_loading("Loading tasks...") do
        # Don't cache tasks as they change frequently
        @tasks_data = @client.get_tasks(@current_context[:list_id])
      end
      
      if @tasks_data.empty?
        Display.show_info("No tasks found in this list")
        sleep(2)
        navigate_back
        return
      end
      
      # Group tasks by status for better organization
      grouped_tasks = group_tasks_by_status(@tasks_data)
      
      choices = build_task_choices(grouped_tasks)
      add_navigation_choices(choices)
      
      # Show tasks table first
      Display.show_tasks_table(@tasks_data, "Tasks in #{@current_context[:list_name]}")
      
      selection = @prompt.select("Select a Task:", choices, per_page: 20)
      
      if selection[:type] == :task
        push_context(:task_detail, 
          task_id: selection[:id], 
          task_name: selection[:name])
      else
        handle_navigation_selection(selection)
      end
    end
    
    def show_task_detail
      task_data = fetch_with_cache("task_#{@current_context[:task_id]}", ttl: 60) do
        @client.get_task(@current_context[:task_id])
      end
      
      Display.show_task_detail(task_data)
      
      choices = [
        { name: "🔄 Refresh", value: { type: :refresh } },
        { name: "⬅️  Back to Tasks", value: { type: :back } },
        { name: "🏠 Home", value: { type: :home } }
      ]
      
      selection = @prompt.select("Actions:", choices)
      
      case selection[:type]
      when :refresh
        # Clear cache for this task and stay in current context
        @cache.delete("task_#{@current_context[:task_id]}")
      when :back
        navigate_back
      when :home
        navigate_home
      end
    end
    
    def prompt_continue_or_quit
      choice = @prompt.select("What would you like to do?", [
        { name: "🔄 Try again", value: :retry },
        { name: "⬅️  Go back", value: :back },
        { name: "🏠 Go to home", value: :home },
        { name: "🚪 Exit", value: :exit }
      ])
      
      case choice
      when :retry
        # Stay in current context
      when :back
        navigate_back
      when :home
        navigate_home
      when :exit
        exit(0)
      end
    end
    
    # Helper methods for navigation
    
    def push_context(type, **attributes)
      @navigation_stack.push(@current_context.dup)
      @current_context = { type: type, **attributes }
    end
    
    def navigate_back
      return navigate_home if @navigation_stack.empty?
      @current_context = @navigation_stack.pop
    end
    
    def navigate_home
      @navigation_stack.clear
      @current_context = { type: :workspaces }
    end
    
    def fetch_with_cache(key, ttl: nil)
      cached_data = @cache.get(key)
      return cached_data if cached_data
      
      data = yield
      @cache.set(key, data)
      data
    end
    
    def build_workspace_choices(workspaces_data)
      workspaces_data.map do |ws_data|
        workspace = Models::Workspace.new(ws_data)
        {
          name: workspace.to_s,
          value: { id: workspace.id, name: workspace.name, type: :workspace }
        }
      end
    end
    
    def build_space_choices(spaces_data)
      spaces_data.map do |space_data|
        space = Models::Space.new(space_data)
        {
          name: space.to_s,
          value: { id: space.id, name: space.name, type: :space }
        }
      end
    end
    
    def build_folder_choices(folders_data)
      folders_data.map do |folder_data|
        folder = Models::Folder.new(folder_data)
        {
          name: folder.to_s,
          value: { id: folder.id, name: folder.name, type: :folder }
        }
      end
    end
    
    def build_list_choices(lists_data, prefix: "")
      lists_data.map do |list_data|
        list = Models::List.new(list_data)
        {
          name: "#{prefix}#{list.to_s}",
          value: { id: list.id, name: list.name, type: :list }
        }
      end
    end
    
    def build_task_choices(grouped_tasks)
      choices = []
      
      grouped_tasks.each do |status, tasks|
        # Add separator for each status group
        if choices.any?
          choices << { name: "", value: { type: :separator }, disabled: "" }
        end
        
        choices << { 
          name: "#{status} (#{tasks.size})", 
          value: { type: :separator }, 
          disabled: "" 
        }
        
        tasks.each do |task_data|
          task = Models::Task.new(task_data)
          choices << {
            name: "  #{task.to_s}",
            value: { id: task.id, name: task.name, type: :task }
          }
        end
      end
      
      choices
    end
    
    def group_tasks_by_status(tasks_data)
      grouped = {}
      
      tasks_data.each do |task_data|
        status_name = task_data.dig('status', 'status') || 'Unknown Status'
        grouped[status_name] ||= []
        grouped[status_name] << task_data
      end
      
      # Sort by typical workflow order
      status_order = ['To Do', 'Open', 'In Progress', 'In Review', 'Done', 'Closed', 'Complete']
      
      sorted_grouped = {}
      status_order.each do |status|
        if grouped[status]
          sorted_grouped[status] = grouped[status]
          grouped.delete(status)
        end
      end
      
      # Add any remaining statuses
      grouped.each { |status, tasks| sorted_grouped[status] = tasks }
      
      sorted_grouped
    end
    
    def add_navigation_choices(choices)
      choices << { name: "⬅️  Back", value: { type: :back } }
      choices << { name: "🏠 Home", value: { type: :home } }
    end
    
    def handle_navigation_selection(selection, next_type = nil, id_key = nil, name_key = nil)
      case selection[:type]
      when :back
        navigate_back
      when :home
        navigate_home
      else
        if next_type && id_key && name_key
          push_context(next_type, 
            id_key => selection[:id], 
            name_key => selection[:name])
        end
      end
    end
  end
end