module tokentype

pub enum TokenType {
	number
	newline
	operator
	eof
	unknown
	add
	sub
	multiply
	divide
	left_paren
	right_paren
	assignment
	less
	greater
	equal
	notequal
	lessequal
	greaterequal
	not
	@or
	and
}