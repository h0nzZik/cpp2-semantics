
module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Unambiguous

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
                             | "(" Expressions ")"                                                   [seqstrict(parse), hybrid(Unambiguous)]
                             | UnnamedDeclaration

  syntax PostfixExpression ::= PrimaryExpression
                             | PostfixExpression PostfixOperator  [seqstrict(parse)] // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"  [seqstrict(parse)] // TODO nonempty list of expressions
                             | PostfixExpression "(" Expressions ")"                                  [seqstrict(parse), hybrid(Unambiguous)]
                             //| PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression                                     [seqstrict(parse), hybrid(Unambiguous)]


  syntax PrefixExpression ::= PostfixExpression
                            | PrefixOperator PrefixExpression                                         [seqstrict(parse), hybrid(Unambiguous)]

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    | MultiplicativeExpression "*" IsAsExpression                      [seqstrict(parse), hybrid(Unambiguous)]
                                    | MultiplicativeExpression "/" IsAsExpression                      [seqstrict(parse), hybrid(Unambiguous)]
                                    | MultiplicativeExpression "%" IsAsExpression                      [seqstrict(parse), hybrid(Unambiguous)]
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              | AdditiveExpression "+" MultiplicativeExpression                        [seqstrict(parse), hybrid(Unambiguous)]
                              | AdditiveExpression "-" MultiplicativeExpression                        [seqstrict(parse), hybrid(Unambiguous)]


  syntax ShiftExpression ::= AdditiveExpression
                           | ShiftExpression "<<" AdditiveExpression                                   [seqstrict(parse), hybrid(Unambiguous)]
                           | ShiftExpression ">>" AdditiveExpression                                   [seqstrict(parse), hybrid(Unambiguous)]

  syntax CompareExpression ::= ShiftExpression
                             | CompareExpression "<=>" ShiftExpression                                 [seqstrict(parse), hybrid(Unambiguous)]

  syntax RelationalExpression ::= CompareExpression
                                | RelationalExpression "<"  CompareExpression                          [seqstrict(parse), hybrid(Unambiguous)]
                                | RelationalExpression ">"  CompareExpression                          [seqstrict(parse), hybrid(Unambiguous)]
                                | RelationalExpression "<=" CompareExpression                          [seqstrict(parse), hybrid(Unambiguous)]
                                | RelationalExpression ">=" CompareExpression                          [seqstrict(parse), hybrid(Unambiguous)]

  syntax EqualityExpression ::= RelationalExpression
                              | EqualityExpression "==" RelationalExpression                           [seqstrict(parse), hybrid(Unambiguous)]
                              | EqualityExpression "!=" RelationalExpression                           [seqstrict(parse), hybrid(Unambiguous)]

  syntax BitAndExpression ::= EqualityExpression
                            | BitAndExpression "&" EqualityExpression                                  [seqstrict(parse), hybrid(Unambiguous)]

  syntax BitXorExpression ::= BitAndExpression
                            | BitXorExpression "^" BitAndExpression                                    [seqstrict(parse), hybrid(Unambiguous)]

  syntax BitOrExpression ::= BitXorExpression
                           | BitOrExpression "|" BitXorExpression                                      [seqstrict(parse), hybrid(Unambiguous)]

  syntax LogicalAndExpression ::= BitOrExpression
                                | LogicalAndExpression "&&" BitOrExpression                            [seqstrict(parse), hybrid(Unambiguous)]


  syntax LogicalOrExpression ::= LogicalAndExpression
                               | LogicalOrExpression "||" LogicalAndExpression                         [seqstrict(parse), hybrid(Unambiguous)]

  syntax AssignmentExpression ::= LogicalOrExpression
  //                              | AssignmentExpression AssignmentOperator AssignmentExpression
                                | AssignmentExpression AssignmentOperator LogicalOrExpression          [seqstrict(parse), hybrid(Unambiguous)]

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}                                                          [seqstrict(parse), hybrid(Unambiguous)]
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}                                           [seqstrict(parse), hybrid(Unambiguous)]

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"                                        [seqstrict(parse), hybrid(Unambiguous)]

  syntax UnqualifiedId ::= "const" Identifier                                                          [seqstrict(parse), hybrid(Unambiguous)]
                         |         Identifier
                         | "const" TemplateId                                                          [seqstrict(parse), hybrid(Unambiguous)]
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId                                             [seqstrict(parse), hybrid(Unambiguous)]
                        | MemberNameSpecifier UnqualifiedId                                            [seqstrict(parse), hybrid(Unambiguous)]

  syntax MemberNameSpecifier ::= UnqualifiedId "."                                                     [seqstrict(parse), hybrid(Unambiguous)]

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"                                                    [seqstrict(parse), hybrid(Unambiguous)]

  syntax IdExpression ::= QualifiedId    [hybrid(Unambiguous)]
                        > UnqualifiedId  [hybrid(Unambiguous)]

  syntax ExpressionStatement ::= Expression ";"                                                        [seqstrict(parse), hybrid(Unambiguous)]
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement                          [seqstrict(parse), hybrid(Unambiguous)]
                              | "if"             Expression CompoundStatement                          [seqstrict(parse), hybrid(Unambiguous)]
                              | "if" "constexpr" Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(Unambiguous)]
                              | "if"             Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(Unambiguous)]
                              

  syntax ReturnStatement ::= "return" Expression ";"                                                   [seqstrict(parse), hybrid(Unambiguous)]
                           | "return" ";"
 
  syntax IterationStatement ::= "while" LogicalOrExpression NextClause CompoundStatement               [seqstrict(parse), hybrid(Unambiguous)]
                              | "while" LogicalOrExpression            CompoundStatement               [seqstrict(parse), hybrid(Unambiguous)]
                              | "do" CompoundStatement "while" LogicalOrExpression NextClause ";"      [seqstrict(parse), hybrid(Unambiguous)]
                              | "do" CompoundStatement "while" LogicalOrExpression            ";"      [seqstrict(parse), hybrid(Unambiguous)]
                              | "for" Expression NextClause "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(Unambiguous)]
                              | "for" Expression            "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(Unambiguous)]


  syntax NextClause ::= "next" AssignmentExpression                                                    [seqstrict(parse), hybrid(Unambiguous)]

  syntax IsTypeConstraint ::= "is" IdExpression                                                        [seqstrict(parse), hybrid(Unambiguous)]

  syntax AsTypeCast ::= "as" IdExpression                                                              [seqstrict(parse), hybrid(Unambiguous)]

  syntax AltName ::= UnqualifiedId ":"                                                                 [seqstrict(parse), hybrid(Unambiguous)]

  syntax Alternative ::= AltName IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(Unambiguous)]
                       | AltName AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(Unambiguous)]
                       |         IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(Unambiguous)]
                       |         AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(Unambiguous)]

  syntax Alternatives ::= List{Alternative,""}

  syntax InspectExpression ::= "inspect" "constexpr" Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect" "constexpr" Expression                   "{"              "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect"             Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect"             Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect"             Expression                   "{"              "}" [seqstrict(parse), hybrid(Unambiguous)]
                             | "inspect"             Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(Unambiguous)]



  syntax Statement ::= "let" ParameterDeclarationList Statement                                [seqstrict(parse), hybrid(Unambiguous)]
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | Declaration
                     | ExpressionStatement
                     | Contract

  syntax Statements ::= List{Statement,""}                                                     [seqstrict(parse), hybrid(Unambiguous)]

  syntax CompoundStatement ::= "{" Statements "}"                                              [seqstrict(parse), hybrid(Unambiguous)]
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration                               [seqstrict(parse), hybrid(Unambiguous)]
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}                              [seqstrict(parse), hybrid(Unambiguous)]
  syntax ParameterDeclarationList ::= "(" ParameterDeclarations ")"                            [seqstrict(parse), hybrid(Unambiguous)]

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(Unambiguous)]
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(Unambiguous)]
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(Unambiguous)]
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(Unambiguous)]

  syntax ReturnList ::= "->" IdExpression                                                      [seqstrict(parse), hybrid(Unambiguous)]
                      | "->" ParameterDeclarationList                                          [seqstrict(parse), hybrid(Unambiguous)]

  syntax Contracts ::= List{Contract,""}                                                       [seqstrict(parse), hybrid(Unambiguous)]

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts               [seqstrict(parse), hybrid(Unambiguous)]
                        | ParameterDeclarationList          ReturnList Contracts               [seqstrict(parse), hybrid(Unambiguous)]

  syntax UnnamedDeclaration ::= ":" FunctionType "=" Statement                                 [seqstrict(parse), hybrid(Unambiguous)]
                              | ":" IdExpression "=" Statement                                 [seqstrict(parse), hybrid(Unambiguous)]
                              | ":"              "=" Statement                                 [seqstrict(parse), hybrid(Unambiguous)]
                              | ":" IdExpression                                               [seqstrict(parse), hybrid(Unambiguous)]

  syntax Declaration ::= Identifier UnnamedDeclaration                                         [seqstrict(parse), hybrid(Unambiguous)]
  syntax Declarations ::= List{Declaration,""}                                                 [seqstrict(parse), hybrid(Unambiguous)]
  syntax TranslationUnit ::= Declarations 

endmodule
