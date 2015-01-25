require "envy/version"
require "envy/environment"
require "envy/dsl"

module Envy
  attr_writer :env

  def env
    @env ||= Envy::Environment.new
  end

  extend self
end

require "envy/railtie" if defined?(Rails)
