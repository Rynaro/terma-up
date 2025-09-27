# frozen_string_literal: true

module ClickupTui
  module Models
    class Folder
      attr_reader :id, :name, :orderindex, :task_count, :archived, :hidden

      def initialize(data)
        @id = data['id']
        @name = data['name']
        @orderindex = data['orderindex']
        @task_count = data['task_count'] || 0
        @archived = data['archived'] || false
        @hidden = data['hidden'] || false
      end

      def to_s
        status_icon = archived ? '📦' : '📁'
        "#{status_icon} #{name}"
      end

      def display_name
        status = archived ? ' (Archived)' : ''
        count = task_count.positive? ? " (#{task_count} tasks)" : ''
        "#{name}#{status}#{count}"
      end
    end
  end
end
