module tokenizer
import token
import tokentype { TokenType }

enum TokenizeState {
	default
	operator
	number
}

const (
	plus = '+'[0]
	minus = '-'[0]
	mult = '*'[0]
	div = '/'[0]
	lparen = '('[0]
	rparen = ')'[0]
	numbers = [`0`,`1`,`2`,`3`,`4`,`5`,`6`,`7`,`8`,`9`]
	less = '<'[0]
	greater = '>'[0]
	equal = '='[0]
	not = '!'[0]
	logic_or = '|'[0]
	logic_and = '&'[0]
)

fn is_op(chr byte) bool {
	add_op := chr == plus || chr == minus
	mul_op := chr == mult || chr == div
	comp_op := chr == less || chr == greater || chr == equal
	logic_op := chr == not || chr == logic_or || chr == logic_and
	return add_op || mul_op || comp_op || logic_op
}

fn find_op_type(first_operator byte, next_char byte) TokenType {
	mut tok_type := TokenType.unknown
	match first_operator {
		plus { tok_type = TokenType.add }
		minus { tok_type = TokenType.sub }
		mult { tok_type = TokenType.multiply }
		div { tok_type = TokenType.divide }
		less {
				tok_type = TokenType.less
				if next_char == equal {
					tok_type = TokenType.lessequal
				}
			}
		greater {
					tok_type = TokenType.greater
					if next_char == equal {
						tok_type = TokenType.greaterequal
					}
				}
		equal {
				tok_type = TokenType.assignment
				if next_char == equal {
					tok_type = TokenType.equal
				}
			  }
		not {
				tok_type = TokenType.not
				if next_char == equal {
					tok_type = TokenType.notequal
				}
			}
		logic_or { tok_type = TokenType.@or }
		logic_and { tok_type = TokenType.and }
		else { /*Nothing*/ }
	}
	return tok_type
}

fn is_paren(chr byte) bool {
	prnt_op := chr == lparen || chr == rparen
	return prnt_op
}

fn find_paren_type(chr byte) TokenType {
	mut ttype := TokenType.unknown
	match chr {
		lparen { ttype = TokenType.left_paren }
		rparen { ttype = TokenType.right_paren }
		else { /*Nothing*/ }
	}
	return ttype
}

pub fn tokenize(source string) []token.Token {
	mut tokens := []token.Token{}

	mut tok := token.Token{}
	mut token_text := ""
	mut first_operator := '0'[0]
	mut state := TokenizeState.default

	for index := 0; index < source.len; index++ {
		chr := source[index]
		match state {
			.default {
				if is_op(chr) {
					first_operator = chr
					op_type := find_op_type(first_operator, '0'[0])
					tok = token.new(op_type, chr.ascii_str())
					state = .operator
				} else if is_digit(chr) {
					token_text += chr.ascii_str()
					state = .number
				} else if is_paren(chr) {
					paren_type := find_paren_type(chr)
					tokens << token.new(paren_type, chr.ascii_str())
				}
			}
			.operator {
				if is_op(chr) {
					op_type := find_op_type(first_operator, chr)
					tok = token.new(op_type, first_operator.ascii_str() + chr.ascii_str())
				} else {
					tokens << tok
					state = .default
					index -= 1
				}
			}
			.number {
				if is_digit(chr) {
					token_text += chr.ascii_str()
				} else {
					tokens << token.new(TokenType.number, token_text)
					token_text = ""
					state = .default
					index -= 1
				}
			}
		}
	}

	return tokens
}

pub fn pretty_print(tokens []token.Token) {
	mut number_count := 0
	mut op_count := 0

	for token in tokens {
		if token.category == TokenType.number {
			println("Number....: $token.lexeme")
			number_count += 1
		} else {
			println("Operator..: $token.category")
			op_count += 1
		}
	}
	println("You have got $number_count different number and $op_count operators.")
}

fn is_digit(ch byte) bool {
	return ch in numbers
}

