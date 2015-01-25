module Envy
  class Variable
    attr_reader :environment, :name, :options

    # environment           - an instance of Envy::Environment
    # name                  - the name of the environment variable
    # options[:description] - a friendly description of the environment variable
    # options[:required]    - a boolean indiciting if a value is required
    # options[:default]     - a default value or Proc if the variable is not set
    # options[:from]        - the environment variable to fetch the value from
    def initialize(environment, name, options = {}, &default)
      @environment = environment
      @name = name
      @options = {:required => true}.merge(options)
      @default = default || options[:default]
    end

    # Determine if this variable is required.
    #
    # If `options[:required]` is a Proc or symbol, it will be instance evaled
    # in the environment.
    #
    #     desc "Should SSL be required?"
    #     boolean :force_ssl, :default => true
    #
    #     desc "PEM file with encryption keys"
    #     string :pem, :required => :force_ssl?
    #
    # Returns true if the variable is required.
    def required?
      if options[:required].respond_to?(:to_proc)
        environment.instance_eval(&options[:required])
      else
        !!options[:required]
      end
    end

    # The default value for this variable when it is not set in the environment.
    def default
      if @default.respond_to?(:to_proc)
        environment.instance_eval(&@default)
      else
        @default
      end
    end

    # The name of the reader method that will be defined on the `environment`
    # instance. Override in subclasses to customize.
    def method_name
      name
    end

    # The method that gets defined on the environment to read this variable.
    #
    # Returns the cast environment variable.
    def value
      return @value if defined?(@value)

      @value = cast(fetch).tap do |result|
        raise ArgumentError, "#{name} is required" if required? && result.nil?
      end
    end

    # Fetch the value from the environment
    #
    # Returns a string from the environment variable, or the default value.
    def fetch
      environment.source.fetch(from) { default }
    end

    # The name of the environment variable to fetch the value from.
    def from
      @from ||= options.fetch(:from) { name.to_s.upcase }
    end

    # Override in subclasses to perform casting.
    #
    # value - A string from the environment, or the default value
    def cast(value)
      value
    end

    # Unset the memoized value.
    def reset
      remove_instance_variable(:@value)
    end
  end
end
