require "addressable/uri"
require "addressable/template"

module Envy
  module Type
    class URI < Variable
      def initialize(dsl, name, template: nil, **args, &block)
        super dsl, name, **args, &block

        @template = Addressable::Template.new(template) if template
      end

      def cast(value)
        return unless value

        Addressable::URI.parse(value).tap do |uri|
          if @template && !@template.match(uri)
            raise ArgumentError, "#{name} must match #{@template.pattern.inspect}"
          end
        end
      end
    end
  end
end
