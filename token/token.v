module token
import tokentype { TokenType }

pub struct Token {
	pub mut:
		category TokenType
		lexeme string
}

pub fn new(c TokenType, l string) Token {
	return Token{
		category: c,
		lexeme: l,
	}
}

pub fn (t Token) to_string() string {
	return "<Category: $t.category Lexeme: $t.lexeme>"
}