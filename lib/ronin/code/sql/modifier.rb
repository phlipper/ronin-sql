module Ronin
  module Code
    module SQL
      class Modifier

        include Emitable

        def initialize(program,expr,name)
          @program = program

          @expr = expr
          @name = name
        end

        def emit
          emit_value(@expr) + [keyword(@name)]
        end
      end
    end
  end
end