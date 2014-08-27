module Envy
  class Environment
    include Enumerable

    attr_reader :env

    def initialize(env = ENV)
      @env = env
      @variables = {}
      extend readers
    end

    def configure(filename = "Envfile")
      Envy::DSL.new(self).eval(filename)
      self
    end

    def readers
      @readers ||= Module.new
    end

    def add(variable)
      @variables[variable.name] = variable
      readers.send :define_method, variable.method_name, &variable.method(:value)
    end

    def [](name)
      @variables[name]
    end

    def each(&block)
      @variables.values.each(&block)
    end

    # Reset memoized values for all variables
    def reset
      @variables.values.each(&:reset)
    end
  end
end
