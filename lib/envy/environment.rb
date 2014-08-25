module Envy
  class Environment
    include Enumerable

    attr_reader :env

    def initialize(env = ENV)
      @env = env
      @variables = {}
      extend accessors
    end

    def accessors
      @accessors ||= Module.new
    end

    def add(variable)
      @variables[variable.name] = variable
      accessors.send :define_method, variable.accessor_name, &variable.method(:accessor)
    end

    def [](name)
      @variables[name]
    end

    def each(&block)
      @variables.values.each(&block)
    end
  end
end
