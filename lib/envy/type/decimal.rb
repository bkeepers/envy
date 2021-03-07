require "bigdecimal"

module Envy
  module Type
    # A Decimal environment variable
    #
    # Numeric values get cast into a decimal.
    class Decimal < Variable
      def cast(value)
        BigDecimal(value) if value
      end
    end
  end
end