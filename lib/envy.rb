require "envy/version"
require "envy/environment"
require "envy/dsl"

module Envy
  attr_writer :environment

  def environment
    @environment ||= Envy::Environment.new
  end

  extend self
end

require "envy/railtie" if defined?(Rails)
