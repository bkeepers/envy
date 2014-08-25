require "addressable/uri"
require "addressable/template"

module Envy
  class URI < Variable
    def template
      @template ||= Addressable::Template.new(options[:template]) if options[:template]
    end

    def cast(value)
      return unless value

      Addressable::URI.parse(value).tap do |uri|
        if template && !template.match(uri)
          raise ArgumentError, "#{name} must match #{template.pattern.inspect}"
        end
      end
    end
  end
end
