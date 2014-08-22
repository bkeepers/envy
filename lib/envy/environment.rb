module Envy
  class Environment
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
      accessors.send :define_method, variable.accessor_name do
        variable.accessor(self)
      end
    end

    def [](name)
      @variables[name]
    end
  end
end
