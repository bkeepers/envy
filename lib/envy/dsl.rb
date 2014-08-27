require "envy/variable"
require "envy/integer"
require "envy/boolean"
require "envy/uri"
require "envy/decimal"

module Envy
  class DSL
    attr_reader :environment

    def initialize(environment)
      @environment = environment
    end

    def desc(description)
      @last_description = description
    end

    def string(name, options = {}, &default)
      add Variable.new(environment, name, options, &default)
    end

    def integer(name, options = {}, &default)
      add Integer.new(environment, name, options, &default)
    end

    def boolean(name, options = {}, &default)
      add Boolean.new(environment, name, options, &default)
    end

    def uri(name, options = {}, &default)
      add URI.new(environment, name, options, &default)
    end

    def decimal(name, options = {}, &default)
      add Decimal.new(environment, name, options, &default)
    end

    def eval(filename)
      raise EnvfileNotFound, "#{filename} not found" unless File.exists?(filename)
      contents = File.read(filename)
      super contents, binding, filename.to_s, 1
    end
    public :eval

    def add(variable)
      variable.options[:description] ||= last_description
      environment.add variable
    end

    def last_description
      @last_description.tap { @last_description = nil }
    end
  end
end
