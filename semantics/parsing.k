requires "syntax.k"

module PARSING
  imports CPP2-SYNTAX 
  imports K-AMBIGUITIES
  imports DOMAINS

  //syntax KItem ::= disambiguate(TranslationUnit)
  //configuration <T> <k> disambiguate($PGM:TranslationUnit) </k> </T>
  configuration <T> <k> $PGM:TranslationUnit </k> </T>

  rule isUnambiguous(amb(_,_)) => false
  rule isUnambiguous(_:Identifier) => true
  rule isUnambiguous(_) => true [owise]

  context alias [parse]: <k> HERE:K ... </k> [result(Unambiguous)]

  syntax KItem ::= disambiguate(KItem, KItem)
  rule amb(X:Statements, Y:Statements) => disambiguate(X, Y)
  rule amb(X:ExpressionStatement, Y:ExpressionStatement) => disambiguate(X, Y)
  rule amb(X:AssignmentExpression, Y:AssignmentExpression) => disambiguate(X, Y)

/*
  rule disambiguate(
    ((_Y:Identifier):Statement _:Statements) #as _Stmts1:Statements,
    ((_D:Declaration):Statement _:Statements) #as Stmts2:Statements
  ) => Stmts2
  // the same but symmetric
  rule disambiguate(
    ((_D:Declaration):Statement _:Statements) #as Stmts2:Statements,
    ((_Y:Identifier):Statement _:Statements) #as _Stmts1:Statements
  ) => Stmts2
*/

/*
  rule disambiguate(
    D:Declaration,
    ( _:Identifier (: _:IdExpression = (_ES:Expression ;):Statement):UnnamedDeclaration):Declaration
  ) => D
*/
  //rule disambiguate((X:Statement XS:Statements):Statements, (Y:Statement YS:Statements):Statements)
  //=> (amb(X,Y):Statement (amb(XS, YS)):Statements):Statements

  //rule disambiguate((ID:Identifier amb(UD1:UnnamedDeclaration,UD2:UnnamedDeclaration)):Declaration, (ID:Identifier UD2:UnnamedDeclaration):Declaration)

  //rule disambiguate((ID:Identifier UD1:UnnamedDeclaration):Declaration, (ID:Identifier UD2:UnnamedDeclaration):Declaration)
  //  => (ID (amb(UD1, UD2)):UnnamedDeclaration):Declaration

endmodule