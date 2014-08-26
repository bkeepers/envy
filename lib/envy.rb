require "envy/version"
require "envy/environment"
require "envy/dsl"

module Envy
  def self.env
    @env ||= Envy::Environment.new
  end

  def self.configure(filename = "Envfile")
    Envy::DSL.new(env).eval(filename)
  end
end
