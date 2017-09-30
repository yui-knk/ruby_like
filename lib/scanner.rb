require_relative "./token"

module Scanner
  def self.create(string, verbose)
    Scanner.new(string, verbose)
  end

  class Scanner
    def initialize(string, verbose)
      @string = string
      @pos = 0
      @verbose = verbose
    end

    # return [token, literal_string]
    def scan
      r = scan0

      if @verbose
        p r
      end

      r
    end

    private

    def scan0
      skip_white_spaces
      # skip_break_line

      return [Token::EOF, nil] if eof?

      case
      when char == "("
        go_next
        return [Token::Lparen, "("]
      when char == ")"
        go_next
        return [Token::Rparen, ")"]
      when char == ","
        go_next
        return [Token::Comma, ","]
      when is_letter?(char)
        lit = scan_keyword

        return [Token::Boolean, lit] if lit == "true"
        return [Token::Boolean, lit] if lit == "false"
        return [Token::Def, lit] if lit == "def"
        return [Token::End, lit] if lit == "end"
        return [Token::If, lit] if lit == "if"
        return [Token::Then, lit] if lit == "then"
        return [Token::Else, lit] if lit == "else"
        return [Token::Ident, lit]
      when is_digit?(char)
        lit = scan_interger

        return [Token::Integer, lit]
      when is_double_quote?(char)
        lit = scan_stirng

        return [Token::String, lit]
      end
    end

    def char
      @string[@pos]
    end

    def scan_keyword
      buf = ""

      while !eof? && is_letter?(char) do
        buf << char
        go_next
      end

      buf
    end

    def scan_interger
      buf = ""

      while !eof? && is_digit?(char) do
        buf << char
        go_next
      end

      buf
    end

    def scan_stirng
      buf = ""

      while is_double_quote?(char) do
        raise "Unquoted string '#{buf}'" if eof?

        buf << char
        go_next
      end

      buf
    end

    def is_letter?(char)
      ('a' <= char) && (char <= 'z')
    end

    def is_digit?(char)
      ('0' <= char) && (char <= '9')
    end

    def is_double_quote?(char)
      char == "\""
    end

    # def skip_break_line
    #   if char == "\n"
    #     go_next
    #   end
    # end

    def skip_white_spaces
      while char == " " || char == "\n" do
        go_next
      end
    end

    def go_next
      @pos += 1

      if @verbose
        p "go_next: #{char.inspect} at #{@pos}."
      end
    end

    def eof?
      @pos >= @string.length
    end
  end
end
