module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

  syntax WellFormed
  syntax IllFormed

  // based on https://github.com/hsutter/cppfront/blob/main/source/parse.h
  // see also https://github.com/hsutter/cppfront/issues/71

  syntax Literal  ::= Int | String // What about bool?

  syntax Identifier ::= Id

  syntax PrefixOperator ::= "!"
                          | "-"
                          | "+"

  syntax PostfixOperator ::= "++"
                           | "--"
                           | "*"
                           | "&"
                           | "~"
                           | "$"

  syntax AssignmentOperator ::= "="
                              | "*="
                              | "/="
                              | "%="
                              | "+="
                              | "-="
                              | ">>="
                              | "<<="

  syntax PrimaryExpression ::= InspectExpression
                             | IdExpression
                             | Literal
  // This was moved to parsing.k so that we do not accidentally refer to them
  //                           | "(" Expressions ")"                                                   [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | UnnamedDeclaration

  syntax PostfixExpression ::= PrimaryExpression
                             | PostfixExpression PostfixOperator  [seqstrict(c), hybrid(IllFormed, WellFormed)] // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"  [seqstrict(c), hybrid(IllFormed, WellFormed)] // TODO nonempty list of expressions
                             | PostfixExpression "(" Expressions ")"                                  [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             //| PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression                                     [seqstrict(c), hybrid(IllFormed, WellFormed)]


  syntax PrefixExpression ::= PostfixExpression
                            | PrefixOperator PrefixExpression                                         [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    | MultiplicativeExpression "*" IsAsExpression                      [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                    | MultiplicativeExpression "/" IsAsExpression                      [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                    | MultiplicativeExpression "%" IsAsExpression                      [seqstrict(c), hybrid(IllFormed, WellFormed)]
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              | AdditiveExpression "+" MultiplicativeExpression                        [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | AdditiveExpression "-" MultiplicativeExpression                        [seqstrict(c), hybrid(IllFormed, WellFormed)]


  syntax ShiftExpression ::= AdditiveExpression
                           | ShiftExpression "<<" AdditiveExpression                                   [seqstrict(c), hybrid(IllFormed, WellFormed)]
                           | ShiftExpression ">>" AdditiveExpression                                   [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax CompareExpression ::= ShiftExpression
                             | CompareExpression "<=>" ShiftExpression                                 [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax RelationalExpression ::= CompareExpression
                                | RelationalExpression "<"  CompareExpression                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression ">"  CompareExpression                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression "<=" CompareExpression                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression ">=" CompareExpression                          [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax EqualityExpression ::= RelationalExpression
                              | EqualityExpression "==" RelationalExpression                           [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | EqualityExpression "!=" RelationalExpression                           [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax BitAndExpression ::= EqualityExpression
                            | BitAndExpression "&" EqualityExpression                                  [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax BitXorExpression ::= BitAndExpression
                            | BitXorExpression "^" BitAndExpression                                    [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax BitOrExpression ::= BitXorExpression
                           | BitOrExpression "|" BitXorExpression                                      [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax LogicalAndExpression ::= BitOrExpression
                                | LogicalAndExpression "&&" BitOrExpression                            [seqstrict(c), hybrid(IllFormed, WellFormed)]


  syntax LogicalOrExpression ::= LogicalAndExpression
                               | LogicalOrExpression "||" LogicalAndExpression                         [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax AssignmentExpression ::= LogicalOrExpression
  //                              | AssignmentExpression AssignmentOperator AssignmentExpression
                              | AssignmentExpression AssignmentOperator LogicalOrExpression          [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}                                                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}                                           [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"                                        [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax UnqualifiedId ::= "const" Identifier                                                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                         |         Identifier
                         | "const" TemplateId                                                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId                                             [seqstrict(c), hybrid(IllFormed, WellFormed)]
                        | MemberNameSpecifier UnqualifiedId                                            [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax MemberNameSpecifier ::= UnqualifiedId "."                                                     [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"                                                    [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax IdExpression ::= QualifiedId    [hybrid(IllFormed)]
                        > UnqualifiedId  [hybrid(IllFormed)]

  syntax ExpressionStatement ::= Expression ";"                                                        [seqstrict(c), hybrid(IllFormed, WellFormed)]
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "if"             Expression CompoundStatement                          [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "if" "constexpr" Expression CompoundStatement "else" CompoundStatement [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "if"             Expression CompoundStatement "else" CompoundStatement [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              

  syntax ReturnStatement ::= "return" Expression ";"                                                   [seqstrict(c), hybrid(IllFormed, WellFormed)]
                           | "return" ";"
 
  syntax IterationStatement ::= "while" LogicalOrExpression NextClause CompoundStatement               [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "while" LogicalOrExpression            CompoundStatement               [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression NextClause ";"      [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression            ";"      [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "for" Expression NextClause "do" UnnamedDeclaration                    [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | "for" Expression            "do" UnnamedDeclaration                    [seqstrict(c), hybrid(IllFormed, WellFormed)]


  syntax NextClause ::= "next" AssignmentExpression                                                    [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax IsTypeConstraint ::= "is" IdExpression                                                        [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax AsTypeCast ::= "as" IdExpression                                                              [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax AltName ::= UnqualifiedId ":"                                                                 [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax Alternative ::= AltName IsTypeConstraint "=" Statement                                        [seqstrict(c), hybrid(IllFormed, WellFormed)]
                       | AltName AsTypeCast "=" Statement                                              [seqstrict(c), hybrid(IllFormed, WellFormed)]
                       |         IsTypeConstraint "=" Statement                                        [seqstrict(c), hybrid(IllFormed, WellFormed)]
                       |         AsTypeCast "=" Statement                                              [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax Alternatives ::= List{Alternative,""}

  syntax InspectExpression ::= "inspect" "constexpr" Expression                   "{" Alternatives "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{" Alternatives "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression                   "{"              "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{"              "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression                   "{" Alternatives "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{" Alternatives "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression                   "{"              "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{"              "}" [seqstrict(c), hybrid(IllFormed, WellFormed)]



  syntax Statement ::= "let" ParameterDeclarationList Statement                                [seqstrict(c), hybrid(IllFormed, WellFormed)]
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | Declaration
                     | ExpressionStatement
                     | Contract

  syntax Statements ::= List{Statement,""}                                    [seqstrict(c), hybrid(IllFormed, WellFormed)]
  syntax CompoundStatement ::= "{" Statements "}"                                              [seqstrict(c), hybrid(IllFormed, WellFormed)]
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration                               [seqstrict(c), hybrid(IllFormed, WellFormed)]
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}                              [seqstrict(c), hybrid(IllFormed, WellFormed)]
  syntax ParameterDeclarationList ::= "(" ParameterDeclarations ")"                            [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"            [seqstrict(c), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]" [seqstrict(c), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"            [seqstrict(c), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]" [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax ReturnList ::= "->" IdExpression                                                      [seqstrict(c), hybrid(IllFormed, WellFormed)]
                      | "->" ParameterDeclarationList                                          [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax Contracts ::= List{Contract,""}                                                       [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts               [seqstrict(c), hybrid(IllFormed, WellFormed)]
                        | ParameterDeclarationList          ReturnList Contracts               [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax UnnamedDeclaration ::= ":" FunctionType "=" Statement                                 [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | ":" IdExpression "=" Expression ";"                                 [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | ":"              "=" Expression ";"                                [seqstrict(c), hybrid(IllFormed, WellFormed)]
                              | ":" IdExpression                                               [seqstrict(c), hybrid(IllFormed, WellFormed)]
//                              | ":" IdExpression ";"                                           [seqstrict(c), hybrid(IllFormed, WellFormed)]

  syntax Declaration ::= Identifier UnnamedDeclaration                                         [seqstrict(c), hybrid(IllFormed, WellFormed)]
  syntax Declarations ::= List{Declaration,""}                                [seqstrict(c), hybrid(IllFormed, WellFormed)]
  syntax TranslationUnit ::= Declarations 
endmodule
