require "envy/variable"
require "envy/integer"
require "envy/boolean"
require "envy/uri"
require "envy/decimal"

module Envy
  class DSL
    attr_reader :environment

    def initialize(environment)
      @environment = environment

      type :string,  Envy::Variable
      type :boolean, Envy::Boolean
      type :integer, Envy::Integer
    end

    def type(type_name, type_class)
      singleton = class << self; self; end;
      singleton.send :define_method, type_name do |name, *args, &default|
        add type_class.new(environment, name, *args, &default)
      end
    end

    def desc(description)
      @last_description = description
    end

    def uri(name, options = {}, &default)
      add URI.new(environment, name, options, &default)
    end

    def decimal(name, options = {}, &default)
      add Decimal.new(environment, name, options, &default)
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
