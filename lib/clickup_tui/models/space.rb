# frozen_string_literal: true

module ClickupTui
  module Models
    class Space
      attr_reader :id, :name, :color, :private, :statuses, :features
      
      def initialize(data)
        @id = data['id']
        @name = data['name']
        @color = data['color']
        @private = data['private']
        @statuses = data['statuses'] || []
        @features = data['features'] || {}
      end
      
      def to_s
        privacy_icon = private ? "🔒" : "🗂️"
        "#{privacy_icon} #{name}"
      end
      
      def display_name
        privacy = private ? "Private" : "Public"
        "#{name} (#{privacy})"
      end
    end
  end
end