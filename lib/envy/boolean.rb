module Envy
  # A boolean environment variable
  #
  # Boolean-ish values get cast into true/false boolean values.
  class Boolean < Variable
    VALUES = {
      nil => nil, '' => nil,
      '0' => false, 'false' => false, false => false,
      '1' => true, 'true' => true, true => true
    }

    def accessor_name
      "#{name}?"
    end

    def cast(value)
      VALUES.fetch(value) do
        raise ArgumentError, "invalid value for boolean: #{value.inspect}"
      end
    end
  end
end
