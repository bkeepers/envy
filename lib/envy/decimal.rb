require "bigdecimal"

module Envy
  # A Decimal environment variable
  #
  # Numeric values get cast into a decimal.
  class Decimal < Variable
    def cast(value)
      BigDecimal(value) if value
    end
  end
end
