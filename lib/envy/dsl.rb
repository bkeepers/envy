require "envy/type/variable"
require "envy/type/boolean"
require "envy/type/decimal"
require "envy/type/integer"
require "envy/type/uri"

module Envy
  class DSL
    attr_reader :environment

    def initialize(environment)
      @environment = environment

      type :string,  Envy::Type::Variable
      type :boolean, Envy::Type::Boolean
      type :decimal, Envy::Type::Decimal
      type :integer, Envy::Type::Integer
      type :uri,     Envy::Type::URI
    end

    def type(type_name, type_class)
      singleton = class << self; self; end;
      singleton.send :define_method, type_name do |name, **args, &default|
        add type_class.new(environment, name, description: last_description, **args, &default)
      end
    end

    def desc(description)
      @last_description = description
    end

    def eval(filename)
      contents = File.read(filename)
      super contents, binding, filename.to_s, 1
    end
    public :eval

    def add(variable)
      environment.add variable
    end

    def last_description
      @last_description.tap { @last_description = nil }
    end
  end
end
