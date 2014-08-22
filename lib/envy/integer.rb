module Envy
  class Integer < Variable
    def cast(value)
      Integer(value) if value
    end
  end
end
