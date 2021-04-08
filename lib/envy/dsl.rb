require "envy/type/variable"
require "envy/type/boolean"
require "envy/type/decimal"
require "envy/type/integer"
require "envy/type/uri"
require "envy/type/scope"

module Envy
  class DSL
    attr_reader :environment

    def initialize(environment, scope: nil)
      @environment = environment
      @scope = scope

      type :string,  Envy::Type::Variable
      type :boolean, Envy::Type::Boolean
      type :decimal, Envy::Type::Decimal
      type :integer, Envy::Type::Integer
      type :uri,     Envy::Type::URI
      type :scope,   Envy::Type::Scope
    end

    def type(type_name, type_class)
      singleton = class << self; self; end;
      singleton.send :define_method, type_name do |name, **args, &transform|
        environment.add type_class.new(self, name, description: last_description, **args, &transform)
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

    def last_description
      @last_description.tap { @last_description = nil }
    end

    def method_missing(symbol, *args, &block)
      environment.send(symbol, *args, &block)
    end

    def variable_name(name)
      [@scope&.from, name].compact.join("_").upcase
    end

    def respond_to?(symbol, include_all = false)
      super || environment.respond_to?(symbol, include_all)
    end
  end
end
