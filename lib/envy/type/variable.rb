module Envy
  module Type
    class Variable
      attr_reader :dsl, :name, :description

      # dsl  - an instance of Envy::Environment
      # name - the name of the environment variable
      #
      # Options:
      #   description: - a friendly description of the environment variable
      #   required:    - a boolean indiciting if a value is required
      #   default:     - a default value or Proc if the variable is not set
      #   from:        - the name of the environment variable to fetch the value from
      def initialize(dsl, name, description: nil, required: true, default: nil, from: nil, &transform)
        @dsl = dsl
        @name = name
        @description = description
        @required = required
        @default = default
        @from = from
        @transform = transform || lambda { |value| value }
      end

      # Determine if this variable is required.
      #
      # If `required:` is a Proc or symbol, it will be instance evaled
      # in the environment.
      #
      #     desc "Should SSL be required?"
      #     boolean :force_ssl, default: true
      #
      #     desc "PEM file with encryption keys"
      #     string :pem, required: :force_ssl?
      #
      # Returns true if the variable is required.
      def required?
        !!resolve_option(@required)
      end

      # The default value for this variable when it is not set in the environment.
      def default
        resolve_option(@default)
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
        @value ||= resolve_option(@transform, cast(fetch))
      end

      # Returns true if the variable is required an a value is not provided.
      def missing?
        required? && fetch.nil?
      end

      # Fetch the value from the environment
      #
      # Returns a string from the environment variable, or the default value.
      def fetch
        dsl.environment.fetch(from) { default }
      end

      # Name of variable in the environment
      def from
        @from || dsl.variable_name(name)
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

      private

      def resolve_option(option, *args)
        if option.respond_to?(:call)
          option.call(*args)
        elsif option.respond_to?(:to_proc)
          option.to_proc.call(dsl.environment, *args)
        else
          option
        end
      end
    end
  end
end
