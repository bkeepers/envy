module Envy
  # An Integer environment variable
  #
  # Numeric values get cast into an integer.
  class Integer < Variable
    def cast(value)
      Integer(value) if value
    end
  end
end
