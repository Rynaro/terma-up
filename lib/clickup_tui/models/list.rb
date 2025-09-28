# frozen_string_literal: true

module ClickupTui
  module Models
    class List
      attr_reader :id, :name, :orderindex, :content, :status, :priority,
                  :assignee, :task_count, :due_date, :start_date, :folder, :space, :archived

      def initialize(data)
        @id = data['id']
        @name = data['name']
        @orderindex = data['orderindex']
        @content = data['content']
        @status = data['status']
        @priority = data['priority']
        @assignee = data['assignee']
        @task_count = data['task_count'] || 0
        @due_date = data['due_date']
        @start_date = data['start_date']
        @folder = data['folder']
        @space = data['space']
        @archived = data['archived'] || false
      end

      def to_s
        status_icon = archived ? '📦' : '📋'
        "#{status_icon} #{name}"
      end

      def display_name
        status = archived ? ' (Archived)' : ''
        count = task_count.positive? ? " (#{task_count} tasks)" : ''
        "#{name}#{status}#{count}"
      end

      def color_indicator
        return '⚫' if archived

        case priority&.dig('priority')
        when '1', 'urgent'
          '🔴'
        when '2', 'high'
          '🟠'
        when '3', 'normal'
          '🟡'
        when '4', 'low'
          '🟢'
        else
          '⚪'
        end
      end
    end
  end
end
