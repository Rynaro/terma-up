# frozen_string_literal: true

module ClickupTui
  module Models
    class Task
      attr_reader :id, :name, :description, :status, :priority, :assignees,
                  :tags, :due_date, :start_date, :time_estimate, :time_spent,
                  :custom_fields, :dependencies, :list, :folder, :space, :url,
                  :date_created, :date_updated, :date_closed, :archived, :creator
      
      def initialize(data)
        @id = data['id']
        @name = data['name']
        @description = data['description'] || data['text_content']
        @status = data['status']
        @priority = data['priority']
        @assignees = data['assignees'] || []
        @tags = data['tags'] || []
        @due_date = data['due_date']
        @start_date = data['start_date']
        @time_estimate = data['time_estimate']
        @time_spent = data['time_spent']
        @custom_fields = data['custom_fields'] || []
        @dependencies = data['dependencies'] || []
        @list = data['list']
        @folder = data['folder']
        @space = data['space']
        @url = data['url']
        @date_created = data['date_created']
        @date_updated = data['date_updated']
        @date_closed = data['date_closed']
        @archived = data['archived'] || false
        @creator = data['creator']
      end
      
      def to_s
        "#{status_icon} #{name}"
      end
      
      def display_name
        priority_text = priority_label
        assignee_text = assignees.any? ? " → #{assignees.first['username']}" : ""
        "#{name}#{priority_text}#{assignee_text}"
      end
      
      def status_icon
        return "📦" if archived
        
        case status&.dig('status')&.downcase
        when 'to do', 'open'
          "⭕"
        when 'in progress', 'in review'
          "🔄"
        when 'done', 'closed', 'complete'
          "✅"
        when 'blocked'
          "🚫"
        else
          "⚪"
        end
      end
      
      def priority_icon
        case priority&.dig('priority')
        when '1', 'urgent'
          "🔴"
        when '2', 'high'
          "🟠"
        when '3', 'normal'
          "🟡"
        when '4', 'low'
          "🟢"
        else
          "⚪"
        end
      end
      
      def priority_label
        case priority&.dig('priority')
        when '1', 'urgent'
          " [URGENT]"
        when '2', 'high'
          " [HIGH]"
        when '3', 'normal'
          ""
        when '4', 'low'
          " [LOW]"
        else
          ""
        end
      end
      
      def has_due_date?
        due_date && !due_date.empty?
      end
      
      def overdue?
        return false unless has_due_date?
        
        due_timestamp = due_date.to_i
        due_timestamp > 0 && Time.now.to_i > due_timestamp
      end
      
      def due_date_formatted
        return nil unless has_due_date?
        
        timestamp = due_date.to_i
        return nil if timestamp <= 0
        
        time = Time.at(timestamp / 1000) # ClickUp uses milliseconds
        time.strftime("%Y-%m-%d %H:%M")
      end
      
      def estimated_time_formatted
        return nil unless time_estimate
        
        estimate = time_estimate.to_i
        return nil if estimate <= 0
        
        hours = estimate / 3600000 # Convert from milliseconds to hours
        minutes = (estimate % 3600000) / 60000
        
        if hours > 0
          "#{hours}h #{minutes}m"
        else
          "#{minutes}m"
        end
      end
    end
  end
end