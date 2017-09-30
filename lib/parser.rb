require_relative "./ast"
require_relative "./scanner"
require_relative "./token"

module Parser
  def self.create(string, verbose)
    Parser.new(string, verbose)
  end

  def self.create_with_file(file, verbose)
    Parser.new(File.open(file).read, verbose)
  end

  class Parser
    def initialize(string, verbose)
      @scanner = Scanner.create(string, verbose)
      @token = nil
      @literal = nil
    end

    def parse
      next0

      parse_Program
    end

    private

    def next0
      @token, @literal = @scanner.scan
    end

    # Check current token
    # and raise error if token does not match,
    # make progress if token matches.
    def expect(token_const)
      if token_const != @token
        raise "Token does not match, expected: #{token_const}, actual: #{@token} / #{@literal}."
      else
        next0
      end
    end

    # parse_Xxx consume some tokens
    # and return AST.
    def parse_Program
      ary = []

      while (e = parse_Expression) do
        ary << e
      end

      AST::Program.new(ary)
    end

    def parse_Expression
      case @token
      when Token::EOF
        nil
      when Token::Def
        parse_DefineFunc
      when Token::Ident
        parse_CallFunc
      when Token::If
        parse_If
      else
        raise "Can not parse_Expression: #{@literal} (#{@token})."
      end
    end

    def parse_Primitive
      case @token
      when Token::Boolean
        result = generate_Boolean
      when Token::Integer
        result = AST::Integer.new(@literal.to_i)
      when Token::String
        result = AST::String.new(@literal)
      else
        raise "Can not parse_Primitive: #{@literal} (#{@token})."
      end

      next0
      result
    end

    def parse_DefineFunc
      expect(Token::Def)
      name = parse_Ident
      arg_names = parse_ArgNames
      body = parse_FuncBody
      expect(Token::End)

      AST::DefineFunc.new(name, arg_names, body)
    end

    def parse_CallFunc
      name = parse_Ident
      args = parse_CallFuncArgs

      AST::CallFunc.new(name, args)
    end

    def parse_CallFuncArgs
      args = []

      expect(Token::Lparen)

      while (arg = parse_CallFuncArg) do
        args << arg
        break if @token == Token::Rparen
        expect(Token::Comma)
      end

      expect(Token::Rparen)

      args
    end

    def parse_CallFuncArg
      case @token
      when Token::Ident
        parse_CallFunc
      when Token::Boolean, Token::Integer, Token::String
        parse_Primitive
      when Token::If
        parse_If
      else
        raise "Can not parse_CallFuncArg: #{@literal} (#{@token})."
      end
    end

    def parse_Ident
      if @token != Token::Ident
        raise "Should Ident."
      end

      result = AST::Ident.new(@literal)

      next0
      result
    end

    def parse_ArgNames
      names = []

      expect(Token::Lparen)

      while @token == Token::Ident do
        names << parse_Ident
        break if @token == Token::Rparen
        expect(Token::Comma)
      end

      expect(Token::Rparen)

      names
    end

    def parse_FuncBody
      body = []

      while (b = parse_FuncBody2) do
        body << b
        break if @token == Token::End
      end

      AST::Expressions.new(body)
    end

    def parse_FuncBody2
      case @token
      when Token::Ident
        parse_CallFunc
      when Token::Boolean, Token::Integer, Token::String
        parse_Primitive
      when Token::If
        parse_If
      else
        raise "Can not parse_FuncBody: #{@literal} (#{@token})."
      end
    end

    def parse_IfBody
      case @token
      when Token::Ident
        parse_CallFunc
      else
        parse_Primitive
      end
    end

    def parse_If
      expect(Token::If)

      if @token != Token::Boolean
        raise "Should Boolean."
      end
      cond = generate_Boolean
      next0

      expect(Token::Then)
      then_body = parse_IfBody
      expect(Token::Else)
      else_body = parse_IfBody
      expect(Token::End)

      AST::If.new(cond, then_body, else_body)
    end

    def generate_Boolean
      if @literal == "true"
        AST::Boolean.new(1)
      else
        AST::Boolean.new(0)
      end
    end
  end
end
