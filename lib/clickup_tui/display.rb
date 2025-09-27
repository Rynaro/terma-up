# frozen_string_literal: true

require 'tty-table'
require 'tty-spinner'
require 'tty-progressbar'
require 'tty-cursor'
require 'tty-screen'

module ClickupTui
  class Display
    class << self
      def show_welcome
        clear_screen
        puts
        puts "#{bold('🚀 ClickUp TUI (TermaUp)')}"
        puts "#{dim('Unofficial ClickUp Terminal Interface')}"
        puts
        puts "#{dim('Navigate using arrow keys, Enter to select, Esc to go back')}"
        puts
      end
      
      def show_goodbye
        clear_screen
        puts
        puts "#{bold('👋 Thanks for using ClickUp TUI!')}"
        puts "#{dim('Have a productive day!')}"
        puts
      end
      
      def show_loading(message = "Loading...")
        spinner = TTY::Spinner.new("[:spinner] #{message}", format: :dots)
        spinner.auto_spin
        yield if block_given?
        spinner.stop
      end
      
      def show_error(message)
        puts
        puts "#{red('❌ Error:')} #{message}"
        puts
      end
      
      def show_warning(message)
        puts
        puts "#{yellow('⚠️  Warning:')} #{message}"
        puts
      end
      
      def show_info(message)
        puts
        puts "#{blue('ℹ️  Info:')} #{message}"
        puts
      end
      
      def show_success(message)
        puts
        puts "#{green('✅ Success:')} #{message}"
        puts
      end
      
      def show_task_detail(task_data)
        clear_screen
        
        task = task_data.is_a?(Models::Task) ? task_data : Models::Task.new(task_data)
        
        puts
        puts "#{bold('📋 Task Details')}"
        puts "#{dim('─' * terminal_width)}"
        puts
        
        # Task header
        puts "#{bold(task.name)}"
        puts "#{dim("ID: #{task.id}")}"
        puts
        
        # Status and Priority
        status_name = task.status&.dig('status') || 'Unknown'
        status_color = task.status&.dig('color') || '#808080'
        
        puts "#{bold('Status:')} #{task.status_icon} #{status_name}"
        puts "#{bold('Priority:')} #{task.priority_icon} #{task.priority&.dig('priority')&.capitalize || 'None'}"
        puts
        
        # Assignees
        if task.assignees.any?
          assignee_names = task.assignees.map { |a| a['username'] }.join(', ')
          puts "#{bold('Assignees:')} #{assignee_names}"
        else
          puts "#{bold('Assignees:')} #{dim('Unassigned')}"
        end
        puts
        
        # Dates
        if task.due_date_formatted
          due_text = task.overdue? ? red(task.due_date_formatted + ' (OVERDUE)') : task.due_date_formatted
          puts "#{bold('Due Date:')} #{due_text}"
        end
        
        if task.estimated_time_formatted
          puts "#{bold('Estimated Time:')} #{task.estimated_time_formatted}"
        end
        puts
        
        # Tags
        if task.tags.any?
          tag_names = task.tags.map { |tag| tag['name'] }.join(', ')
          puts "#{bold('Tags:')} #{tag_names}"
          puts
        end
        
        # Description
        if task.description && !task.description.strip.empty?
          puts "#{bold('Description:')}"
          puts "#{dim('─' * terminal_width)}"
          puts
          
          # Render description as markdown if possible
          begin
            require_relative 'markdown'
            rendered = Markdown.render(task.description)
            puts rendered
          rescue
            # Fallback to plain text
            puts task.description
          end
        else
          puts "#{dim('No description available')}"
        end
        
        puts
        puts "#{dim('─' * terminal_width)}"
      end
      
      def show_tasks_table(tasks_data, title = "Tasks")
        return show_info("No tasks found") if tasks_data.empty?
        
        tasks = tasks_data.map { |task_data| 
          task_data.is_a?(Models::Task) ? task_data : Models::Task.new(task_data) 
        }
        
        puts
        puts "#{bold(title)} (#{tasks.size})"
        puts
        
        table = TTY::Table.new do |t|
          t.header = ['Status', 'Priority', 'Name', 'Assignee', 'Due Date']
          
          tasks.each do |task|
            assignee = task.assignees.first&.dig('username') || '-'
            due_date = task.due_date_formatted || '-'
            due_date = red(due_date + ' (!)') if task.overdue?
            
            t << [
              task.status_icon,
              task.priority_icon,
              truncate(task.name, 40),
              truncate(assignee, 15),
              due_date
            ]
          end
        end
        
        puts table.render(:unicode, padding: [0, 1], width: terminal_width - 4)
        puts
      end
      
      def show_breadcrumb(navigation_stack, current_context)
        return if navigation_stack.empty? && current_context[:type] == :workspaces
        
        breadcrumb_parts = []
        
        navigation_stack.each do |context|
          case context[:type]
          when :workspaces
            breadcrumb_parts << "🏠 Home"
          when :spaces
            breadcrumb_parts << "🏢 #{context[:workspace_name]}"
          when :folders
            breadcrumb_parts << "🗂️ #{context[:space_name]}"
          when :lists
            breadcrumb_parts << "📁 #{context[:folder_name]}"
          when :tasks
            breadcrumb_parts << "📋 #{context[:list_name]}"
          end
        end
        
        # Add current context
        case current_context[:type]
        when :workspaces
          # Don't add anything for root
        when :spaces
          breadcrumb_parts << "🏢 #{current_context[:workspace_name]}"
        when :folders
          breadcrumb_parts << "🗂️ #{current_context[:space_name]}"
        when :lists
          breadcrumb_parts << "📁 #{current_context[:folder_name]}"
        when :tasks
          breadcrumb_parts << "📋 #{current_context[:list_name]}"
        when :task_detail
          breadcrumb_parts << "📝 #{current_context[:task_name]}"
        end
        
        if breadcrumb_parts.any?
          puts "#{dim(breadcrumb_parts.join(' > '))}"
          puts
        end
      end
      
      private
      
      def clear_screen
        print TTY::Cursor.clear_screen
        print TTY::Cursor.move_to(0, 0)
      end
      
      def terminal_width
        TTY::Screen.width
      rescue
        80
      end
      
      def terminal_height
        TTY::Screen.height
      rescue
        24
      end
      
      def truncate(text, length)
        return text if text.length <= length
        "#{text[0..length-4]}..."
      end
      
      # Text formatting helpers
      def bold(text)
        "\e[1m#{text}\e[0m"
      end
      
      def dim(text)
        "\e[2m#{text}\e[0m"
      end
      
      def red(text)
        "\e[31m#{text}\e[0m"
      end
      
      def green(text)
        "\e[32m#{text}\e[0m"
      end
      
      def yellow(text)
        "\e[33m#{text}\e[0m"
      end
      
      def blue(text)
        "\e[34m#{text}\e[0m"
      end
      
      def magenta(text)
        "\e[35m#{text}\e[0m"
      end
      
      def cyan(text)
        "\e[36m#{text}\e[0m"
      end
    end
  end
end