require_relative "./evaluator"
require_relative "./parser"

file = ARGV[0]
verbose = !!ARGV[1]
parser = Parser.create_with_file(file, verbose)

ast = parser.parse
p ast if verbose
l = Evaluator.create(ast).evaluate

p "Last value #{l}."
