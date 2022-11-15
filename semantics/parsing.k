requires "syntax.k"

module PARSING
  imports CPP2-SYNTAX 
  imports K-AMBIGUITIES
  //imports DOMAINS

  //syntax KItem ::= disambiguate(TranslationUnit)
  //configuration <T> <k> disambiguate($PGM:TranslationUnit) </k> </T>
  configuration <T> <k> $PGM:TranslationUnit </k> </T>

  syntax KItem ::= disambiguate(KItem, KItem) [function]
  rule amb(X:Statements, Y:Statements) => disambiguate(X, Y) [anywhere]
  rule amb(X:ExpressionStatement, Y:ExpressionStatement) => disambiguate(X, Y) [anywhere]
  rule amb(X:AssignmentExpression, Y:AssignmentExpression) => disambiguate(X, Y) [anywhere]

  rule disambiguate(D:Declaration, _ES:ExpressionStatement) => D [anywhere]
endmodule