module Envy
  # A boolean environment variable
  #
  # Boolean-ish values get cast into true/false boolean values.
  class Boolean < Variable
    def method_name
      "#{name}?"
    end

    def cast(value)
      case value
      when true, /\A(y(es)?|t(rue)?|on|1)\z/i then true
      when false, /\A(n(o)?|f(alse)?|off|0)\z/i then false
      when nil, /\A\s*\z/ then nil
      else raise ArgumentError, "invalid value for boolean: #{value.inspect}"
      end
    end
  end
end
