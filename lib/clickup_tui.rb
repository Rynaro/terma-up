# frozen_string_literal: true

require_relative 'clickup_tui/version'
require_relative 'clickup_tui/error'
require_relative 'clickup_tui/config'
require_relative 'clickup_tui/auth'
require_relative 'clickup_tui/client'
require_relative 'clickup_tui/cache'
require_relative 'clickup_tui/display'
require_relative 'clickup_tui/navigator'
require_relative 'clickup_tui/markdown'
require_relative 'clickup_tui/application'
require_relative 'clickup_tui/cli'

# Load all models
Dir[File.join(__dir__, 'clickup_tui/models/*.rb')].sort.each { |file| require file }

module ClickupTui
  # Module configuration
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Config.new
    yield(configuration)
  end
end
