require "envy/version"
require "envy/environment"
require "envy/dsl"

module Envy
  class Error < StandardError
  end

  class EnvfileNotFound < Error
  end

  attr_writer :env

  def env
    @env ||= Envy::Environment.new
  end

  extend self
end

require "envy/railtie" if defined?(Rails)
