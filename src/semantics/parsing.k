requires "syntax.k"

module PARSING
  imports CPP2-SYNTAX 
  imports BOOL
  imports STRING-SYNTAX
  imports K-AMBIGUITIES

  configuration <T> <k> checkSemicolons($PGM):TranslationUnit </k> </T>

  syntax Expression ::= #SemicolonError(Expression)
  syntax UnnamedDeclaration ::= #SemicolonError(UnnamedDeclaration)
  syntax Declarations ::= checkSemicolons(Declarations)
  syntax Declaration  ::= checkSemicolons(Declaration)
  syntax UnnamedDeclaration ::= checkSemicolons(UnnamedDeclaration)
  syntax Statement     ::= checkSemicolons(Statement)
  syntax Statements    ::= checkSemicolons(Statements)

  syntax Statement ::= #AmbiguityError(Statement, Statement)

  context alias [parse]: <k> HERE:K ... </k> [result(WellFormed)]
  rule isWellFormed(checkSemicolons(_):Declarations) => false
  rule isWellFormed(checkSemicolons(_):Declarations) => false
  rule isWellFormed(checkSemicolons(_):Declaration) => false
  rule isWellFormed(checkSemicolons(_):Statement) => false
  rule isWellFormed(amb(_,_)) => false
  rule isWellFormed(_:Int) => true
  rule isWellFormed(_:String) => true
  rule isWellFormed(_:Identifier) => true
  rule isWellFormed(_:AssignmentOperator) => true

 // These are needed so that we can push it back into `disamb`s.
  rule isWellFormed(#SemicolonError(_):Statement) => true
  rule isWellFormed(#SemicolonError(_):UnnamedDeclaration) => true
  rule isWellFormed(#AmbiguityError(_, _)) => true

  rule checkSemicolons(D:Declaration Ds:Declarations) => (checkSemicolons(D) checkSemicolons(Ds))
  rule checkSemicolons(.Declarations) => .Declarations

  rule checkSemicolons(S:Statement Ss:Statements) => (checkSemicolons(S) checkSemicolons(Ss))
  rule checkSemicolons(.Statements) => .Statements

  syntax KItem ::= disamb(KItem, KItem) [seqstrict(parse)]
  rule amb(X, Y)::Statements => disamb(X, Y)
  rule amb(X, Y)::ExpressionStatement => disamb(X, Y)
  rule amb(X, Y)::Statement => disamb(X, Y)
  rule amb(X, Y)::AssignmentExpression => disamb(X, Y)

  rule disamb(T1, T2) => #AmbiguityError(T1, T2) requires isWellFormed(T1) andBool isWellFormed(T2)

  rule checkSemicolons(amb(L, R))::Declarations => amb(checkSemicolons(L), checkSemicolons(R))
  rule checkSemicolons(amb(L, R))::Declaration => amb(checkSemicolons(L), checkSemicolons(R))
  rule checkSemicolons(amb(L, R))::Statements => amb(checkSemicolons(L), checkSemicolons(R))
  rule checkSemicolons(amb(L, R))::Statement => amb(checkSemicolons(L), checkSemicolons(R))
  rule checkSemicolons(amb(L, R)::ExpressionStatement) => amb(checkSemicolons(L), checkSemicolons(R))
  rule checkSemicolons(amb(L, R))::UnnamedDeclaration => amb(checkSemicolons(L), checkSemicolons(R))

  rule checkSemicolons({ S:Statements }) => { checkSemicolons(S) }
  rule checkSemicolons(X:Id) => #SemicolonError(X)
  rule checkSemicolons(E:Expression ;) => E ;

  rule checkSemicolons((: Id:IdExpression ;)::UnnamedDeclaration ) => (: Id ;)::UnnamedDeclaration
  rule checkSemicolons(: X:IdExpression) => #SemicolonError(: X)
  rule checkSemicolons(: T:FunctionType = Stmt ) => : T = checkSemicolons(Stmt)
  rule checkSemicolons(: T:IdExpression = Stmt ) => : T = checkSemicolons(Stmt)
  rule checkSemicolons(:                = Stmt ) => :   = checkSemicolons(Stmt)

  rule checkSemicolons(X:Identifier Decl:UnnamedDeclaration) => (X checkSemicolons(Decl):UnnamedDeclaration):Declaration
endmodule