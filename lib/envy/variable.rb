module Envy
  class Variable
    attr_reader :name, :options

    def initialize(name, options = {}, &default)
      @name = name
      @options = options
      @default = default || options[:default]
    end

    def required?(context)
      if options[:required].respond_to?(:to_proc)
        context.instance_eval(&options[:required])
      else
        !!options[:required]
      end
    end

    def accessor_name
      name
    end

    def accessor(context)
      cast(value(context)).tap do |result|
        raise ArgumentError, "#{name} is required" if required?(context) && result.nil?
      end
    end

    def value(context)
      context.env.fetch(name.to_s.upcase) do
        if @default.respond_to?(:to_proc)
          context.instance_eval(&@default)
        else
          @default
        end
      end
    end

    def cast(value)
      value
    end
  end
end
