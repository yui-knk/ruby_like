module Token
  tokens = [
    "EOF",
    "Boolean",
    "Integer",
    "String",
    "Def",
    "End",
    "Ident", # for function names
    "Lparen", # "("
    "Rparen", # ")""
    "Comma", # ","
    "If",
    "Then",
    "Else"
  ]

  tokens.each_with_index do |t, i|
    self.class_eval "#{t} = #{i}"
  end
end
