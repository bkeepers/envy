require "envy/variable"
require "envy/integer"
require "envy/boolean"

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
      add Variable.new(name, options, &default)
    end

    def integer(name, options = {}, &default)
      add Integer.new(name, options, &default)
    end

    def boolean(name, options = {}, &default)
      add Boolean.new(name, options, &default)
    end

    def eval(filename)
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
