# frozen_string_literal: true

begin
  require 'tty-markdown'
rescue LoadError
  # Fallback if tty-markdown is not available
end

module ClickupTui
  class Markdown
    class << self
      def render(content, width: nil)
        return content if content.nil? || content.strip.empty?
        
        config = ClickupTui.configuration || Config.new
        render_width = width || config.markdown_width || 80
        
        if defined?(TTY::Markdown)
          begin
            TTY::Markdown.parse(content, width: render_width)
          rescue => e
            # Fallback to simple formatting
            simple_format(content, render_width)
          end
        else
          simple_format(content, render_width)
        end
      end
      
      private
      
      def simple_format(content, width)
        # Simple markdown-like formatting for fallback
        lines = content.split("\n")
        formatted_lines = []
        
        lines.each do |line|
          case line
          when /^# (.+)$/
            formatted_lines << ""
            formatted_lines << "\e[1m\e[4m#{$1}\e[0m"
            formatted_lines << ""
          when /^## (.+)$/
            formatted_lines << ""
            formatted_lines << "\e[1m#{$1}\e[0m"
            formatted_lines << ""
          when /^### (.+)$/
            formatted_lines << ""
            formatted_lines << "\e[1m#{$1}\e[0m"
          when /^\* (.+)$/, /^- (.+)$/
            formatted_lines << "  • #{$1}"
          when /^\d+\. (.+)$/
            formatted_lines << "  #{$&}"
          when /^```/
            # Simple code block handling
            if line == "```"
              formatted_lines << "\e[2m#{line}\e[0m"
            else
              formatted_lines << "\e[2m#{line}\e[0m"
            end
          when /^`([^`]+)`/
            # Inline code
            formatted_lines << line.gsub(/`([^`]+)`/, '\e[2m\1\e[0m')
          when /^\s*$/
            formatted_lines << ""
          else
            # Wrap long lines
            wrapped = wrap_text(line, width)
            formatted_lines.concat(wrapped)
          end
        end
        
        formatted_lines.join("\n")
      end
      
      def wrap_text(text, width)
        return [text] if text.length <= width
        
        words = text.split(' ')
        lines = []
        current_line = ""
        
        words.each do |word|
          if current_line.empty?
            current_line = word
          elsif (current_line + " " + word).length <= width
            current_line += " " + word
          else
            lines << current_line
            current_line = word
          end
        end
        
        lines << current_line unless current_line.empty?
        lines
      end
    end
  end
end