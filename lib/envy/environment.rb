module Envy
  class Environment
    include Enumerable

    attr_reader :source

    def initialize(source = ENV)
      @source = source
      @variables = {}
      extend readers
    end

    # Configure the environment.
    #
    # filename - An optional String path to an Envfile to evaluate.
    # block - An optional block to evaluate.
    #
    # Returns this Environment instance
    def configure(filename = nil, &block)
      dsl = Envy::DSL.new(self)
      dsl.eval(filename) if filename
      dsl.instance_eval(&block) if block
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

    # Iterate over each defined environment variable.
    #
    # Yields an instance of Envy::Variable
    def each(&block)
      @variables.values.each(&block)
    end

    # Reset memoized values for all variables
    def reset
      @variables.values.each(&:reset)
    end

    def validate
      missing = @variables.values.select(&:missing?)
      unless missing.empty?
        raise "Missing environment variables: #{missing.map(&:from).join(', ')}"
      end
    end
  end
end
