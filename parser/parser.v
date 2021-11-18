module parser
import token
import strconv
import tokentype { TokenType }

pub struct Parser {
	pub mut:
		current_token_position int
		tokens []token.Token
}

pub fn new(tokens []token.Token) &Parser {
	return &Parser{
		tokens: tokens,
	}
}
// Token manipulation methods start
fn (mut p Parser) get_token(offset int) token.Token {
	if p.current_token_position + offset >= p.tokens.len {
		return token.new(TokenType.eof, "")
	}
	return p.tokens[p.current_token_position + offset]
}

fn (mut p Parser) current_token() token.Token {
	return p.get_token(0)
}

fn (mut p Parser) next_token() token.Token {
	return p.get_token(1)
}

// Just eats the token(s) given in the offset
fn (mut p Parser) eat_token(offset int) {
	p.current_token_position += offset
}

// Eats the token given type and returns eaten token
fn (mut p Parser) match_and_eat(category TokenType) token.Token {
	mut tok := p.current_token()
	if p.current_token().category != category {
		panic("Saw $tok.category but expected $category")
	} 
	p.eat_token(1)
	return tok
}
// Token manipulation methods end
fn (mut p Parser) multiply() int {
	p.match_and_eat(TokenType.multiply)
	return p.factor()
}

fn (mut p Parser) divide() int {
	p.match_and_eat(TokenType.divide)
	return p.factor()
}

fn (mut p Parser) add() int {
	p.match_and_eat(TokenType.add)
	return p.term()
}

fn (mut p Parser) subtract() int {
	p.match_and_eat(TokenType.sub)
	return p.term()
}

fn (mut p Parser) factor() int {
	mut result := 0
	if p.current_token().category == TokenType.left_paren {
		p.match_and_eat(TokenType.left_paren)
		result = p.arithmetic_expression()
		p.match_and_eat(TokenType.right_paren)
	} else if p.current_token().category == TokenType.number {
		result = strconv.atoi(p.current_token().lexeme) or { panic("invalid conversion.") }
		p.match_and_eat(TokenType.number)
	}
	return result
}

fn (mut p Parser) term() int {
	mut result := p.factor()
	
	for p.current_token().category == TokenType.multiply || 
		p.current_token().category == TokenType.divide {
		cat := p.current_token().category
		match cat {
			.multiply { result *= p.multiply() }
			.divide { result /= p.divide() }
			else { /* nothing */ }
		}
	}
	return result
}

fn (mut p Parser) arithmetic_expression() int {
	mut result := p.term()
	for p.current_token().category == TokenType.add ||
		p.current_token().category == TokenType.sub {
		match p.current_token().category {
			.add { result += p.add() }
			.sub { result -= p.subtract() }
			else { /* nothin */ }
		}
	}
	return result
}

// Boolean parsing start
fn (mut p Parser) less(left_exp_result int) bool {
	p.match_and_eat(TokenType.less)
	return left_exp_result < p.arithmetic_expression()
}

fn (mut p Parser) less_equal(left_exp_result int) bool {
	p.match_and_eat(TokenType.lessequal)
	return left_exp_result <= p.arithmetic_expression()
}

fn (mut p Parser) equal(left_exp_result int) bool {
	p.match_and_eat(TokenType.equal)
	return left_exp_result == p.arithmetic_expression()
}

fn (mut p Parser) greater(left_exp_result int) bool {
	p.match_and_eat(TokenType.greater)
	return left_exp_result > p.arithmetic_expression()
}

fn (mut p Parser) greater_equal(left_exp_result int) bool {
	p.match_and_eat(TokenType.greaterequal)
	return left_exp_result >= p.arithmetic_expression()
}

fn (mut p Parser) relation() bool {
	mut left_exp_result := p.arithmetic_expression()
	mut result := false
	cat := p.current_token().category
	if  cat == TokenType.equal ||
		cat == TokenType.less  ||
		cat == TokenType.greater ||
		cat == TokenType.lessequal ||
		cat == TokenType.greaterequal {
			match cat {
				.less { result = p.less(left_exp_result) }
				.lessequal { result = p.less_equal(left_exp_result) }
				.equal { result = p.equal(left_exp_result) }
				.greater { result = p.greater(left_exp_result) }
				.greaterequal { result = p.greater_equal(left_exp_result) }
				else { /*Nothing*/ }
			}
	}
	return result
}

fn (mut p Parser) boolean_factor() bool {
	return p.relation()
}

fn (mut p Parser) boolean_term() bool {
	mut result := p.boolean_factor()

	for p.current_token().category == TokenType.and {
		p.match_and_eat(TokenType.and)
		result = result && p.boolean_factor()
	}
	return result
}

fn (mut p Parser) boolean_expression() bool {
	mut result := p.boolean_term()
	for p.current_token().category == TokenType.@or {
		p.match_and_eat(TokenType.@or)
		result = result || p.boolean_term()
	}
	return result
}

pub fn (mut p Parser) expression() bool {
	return p.boolean_expression()
}
// Boolean parsing end