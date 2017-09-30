module AST
  class Base
  end

  class Program < Base # Expressions
    attr_reader :expressions

    def initialize(expressions)
      @expressions = expressions
    end
  end

  class Expressions
    attr_reader :expressions

    def initialize(expressions)
      @expressions = expressions
    end
  end

  class Boolean < Base
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Integer < Base
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class String < Base
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Ident < Base
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class DefineFunc < Base
    attr_reader :name, :arg_names, :body

    def initialize(name, arg_names, body)
      @name = name
      @arg_names = arg_names
      @body = body
    end
  end

  class CallFunc < Base
    attr_reader :name, :args

    def initialize(name, args)
      @name = name
      @args = args
    end
  end

  class If < Base
    attr_reader :cond, :then_body, :else_body

    def initialize(cond, then_body, else_body)
      @cond = cond
      @then_body = then_body
      @else_body = else_body
    end
  end
end
