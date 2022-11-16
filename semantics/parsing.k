requires "syntax.k"

module PARSING
  imports CPP2-SYNTAX 
  imports K-AMBIGUITIES
  imports DOMAINS

  configuration <T> <k> $PGM:TranslationUnit </k> </T>

  rule isUnambiguous(amb(_,_)) => false
  rule isUnambiguous(_:Int) => true
  rule isUnambiguous(_:String) => true
  rule isUnambiguous(_:Identifier) => true

  context alias [parse]: <k> HERE:K ... </k> [result(Unambiguous)]

  syntax KItem ::= disambiguate(KItem, KItem)
  rule amb(X:Statements, Y:Statements) => disambiguate(X, Y)
  rule amb(X:ExpressionStatement, Y:ExpressionStatement) => disambiguate(X, Y)
  rule amb(X:AssignmentExpression, Y:AssignmentExpression) => disambiguate(X, Y)

  rule [disamb-1]:
   disambiguate(
    (_X:Identifier _:Statements):Statements,
    (_D:Declaration _:Statements) #as Stmts:Statements
  ) => Stmts
  // a symmetric version of the above
  rule [disamb-1-sym]:
   disambiguate(
    (_D:Declaration _:Statements) #as Stmts:Statements,
    (_X:Identifier _:Statements):Statements
  ) => Stmts

endmodule