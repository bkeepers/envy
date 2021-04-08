module Envy
  module Type
    class Scope < Variable
      def initialize(dsl, name, description: nil, from: nil, &block)
        from ||= dsl.variable_name(name)

        new_dsl = Envy::DSL.new(dsl.environment.dup, scope: self)
        super new_dsl, name, description: description, from: from, required: true
        new_dsl.instance_eval(&block)
      end

      def value
        dsl.environment
      end
    end
  end
end
