# frozen_string_literal: true

module ClickupTui
  module Models
    class Workspace
      attr_reader :id, :name, :color, :avatar, :members

      def initialize(data)
        @id = data['id']
        @name = data['name']
        @color = data['color']
        @avatar = data['avatar']
        @members = data['members'] || []
      end

      def to_s
        "🏢 #{name}"
      end

      def display_name
        "#{name} (#{members.size} members)"
      end
    end
  end
end
