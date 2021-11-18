import tokenizer
import parser

fn main() {
	mut expression := "5+7"
	expression += " "
	println("Expression: $expression")

	tokens := tokenizer.tokenize(expression)
	mut p := parser.new(tokens)

	println("--------------------------")
	tokenizer.pretty_print(tokens)
	println("--------------------------")
	println("Expression result: $p.expression()")
	
}