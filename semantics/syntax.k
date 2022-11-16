module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

  syntax WellFormed

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
                             | "(" Expressions ")"                                                   [seqstrict(parse), hybrid(WellFormed)]
                             | UnnamedDeclaration

  syntax PostfixExpression ::= PrimaryExpression
                             | PostfixExpression PostfixOperator  [seqstrict(parse)] // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"  [seqstrict(parse)] // TODO nonempty list of expressions
                             | PostfixExpression "(" Expressions ")"                                  [seqstrict(parse), hybrid(WellFormed)]
                             //| PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression                                     [seqstrict(parse), hybrid(WellFormed)]


  syntax PrefixExpression ::= PostfixExpression
                            | PrefixOperator PrefixExpression                                         [seqstrict(parse), hybrid(WellFormed)]

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    | MultiplicativeExpression "*" IsAsExpression                      [seqstrict(parse), hybrid(WellFormed)]
                                    | MultiplicativeExpression "/" IsAsExpression                      [seqstrict(parse), hybrid(WellFormed)]
                                    | MultiplicativeExpression "%" IsAsExpression                      [seqstrict(parse), hybrid(WellFormed)]
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              | AdditiveExpression "+" MultiplicativeExpression                        [seqstrict(parse), hybrid(WellFormed)]
                              | AdditiveExpression "-" MultiplicativeExpression                        [seqstrict(parse), hybrid(WellFormed)]


  syntax ShiftExpression ::= AdditiveExpression
                           | ShiftExpression "<<" AdditiveExpression                                   [seqstrict(parse), hybrid(WellFormed)]
                           | ShiftExpression ">>" AdditiveExpression                                   [seqstrict(parse), hybrid(WellFormed)]

  syntax CompareExpression ::= ShiftExpression
                             | CompareExpression "<=>" ShiftExpression                                 [seqstrict(parse), hybrid(WellFormed)]

  syntax RelationalExpression ::= CompareExpression
                                | RelationalExpression "<"  CompareExpression                          [seqstrict(parse), hybrid(WellFormed)]
                                | RelationalExpression ">"  CompareExpression                          [seqstrict(parse), hybrid(WellFormed)]
                                | RelationalExpression "<=" CompareExpression                          [seqstrict(parse), hybrid(WellFormed)]
                                | RelationalExpression ">=" CompareExpression                          [seqstrict(parse), hybrid(WellFormed)]

  syntax EqualityExpression ::= RelationalExpression
                              | EqualityExpression "==" RelationalExpression                           [seqstrict(parse), hybrid(WellFormed)]
                              | EqualityExpression "!=" RelationalExpression                           [seqstrict(parse), hybrid(WellFormed)]

  syntax BitAndExpression ::= EqualityExpression
                            | BitAndExpression "&" EqualityExpression                                  [seqstrict(parse), hybrid(WellFormed)]

  syntax BitXorExpression ::= BitAndExpression
                            | BitXorExpression "^" BitAndExpression                                    [seqstrict(parse), hybrid(WellFormed)]

  syntax BitOrExpression ::= BitXorExpression
                           | BitOrExpression "|" BitXorExpression                                      [seqstrict(parse), hybrid(WellFormed)]

  syntax LogicalAndExpression ::= BitOrExpression
                                | LogicalAndExpression "&&" BitOrExpression                            [seqstrict(parse), hybrid(WellFormed)]


  syntax LogicalOrExpression ::= LogicalAndExpression
                               | LogicalOrExpression "||" LogicalAndExpression                         [seqstrict(parse), hybrid(WellFormed)]

  syntax AssignmentExpression ::= LogicalOrExpression
  //                              | AssignmentExpression AssignmentOperator AssignmentExpression
  //                            | AssignmentExpression AssignmentOperator LogicalOrExpression          [seqstrict(parse), hybrid(WellFormed)]

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}                                                          [seqstrict(parse), hybrid(WellFormed)]
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}                                           [seqstrict(parse), hybrid(WellFormed)]

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"                                        [seqstrict(parse), hybrid(WellFormed)]

  syntax UnqualifiedId ::= "const" Identifier                                                          [seqstrict(parse), hybrid(WellFormed)]
                         |         Identifier
                         | "const" TemplateId                                                          [seqstrict(parse), hybrid(WellFormed)]
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId                                             [seqstrict(parse), hybrid(WellFormed)]
                        | MemberNameSpecifier UnqualifiedId                                            [seqstrict(parse), hybrid(WellFormed)]

  syntax MemberNameSpecifier ::= UnqualifiedId "."                                                     [seqstrict(parse), hybrid(WellFormed)]

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"                                                    [seqstrict(parse), hybrid(WellFormed)]

  syntax IdExpression ::= QualifiedId    [hybrid(WellFormed)]
                        > UnqualifiedId  [hybrid(WellFormed)]

  syntax ExpressionStatement ::= Expression ";"                                                        [seqstrict(parse), hybrid(WellFormed)]
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement                          [seqstrict(parse), hybrid(WellFormed)]
                              | "if"             Expression CompoundStatement                          [seqstrict(parse), hybrid(WellFormed)]
                              | "if" "constexpr" Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(WellFormed)]
                              | "if"             Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(WellFormed)]
                              

  syntax ReturnStatement ::= "return" Expression ";"                                                   [seqstrict(parse), hybrid(WellFormed)]
                           | "return" ";"
 
  syntax IterationStatement ::= "while" LogicalOrExpression NextClause CompoundStatement               [seqstrict(parse), hybrid(WellFormed)]
                              | "while" LogicalOrExpression            CompoundStatement               [seqstrict(parse), hybrid(WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression NextClause ";"      [seqstrict(parse), hybrid(WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression            ";"      [seqstrict(parse), hybrid(WellFormed)]
                              | "for" Expression NextClause "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(WellFormed)]
                              | "for" Expression            "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(WellFormed)]


  syntax NextClause ::= "next" AssignmentExpression                                                    [seqstrict(parse), hybrid(WellFormed)]

  syntax IsTypeConstraint ::= "is" IdExpression                                                        [seqstrict(parse), hybrid(WellFormed)]

  syntax AsTypeCast ::= "as" IdExpression                                                              [seqstrict(parse), hybrid(WellFormed)]

  syntax AltName ::= UnqualifiedId ":"                                                                 [seqstrict(parse), hybrid(WellFormed)]

  syntax Alternative ::= AltName IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(WellFormed)]
                       | AltName AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(WellFormed)]
                       |         IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(WellFormed)]
                       |         AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(WellFormed)]

  syntax Alternatives ::= List{Alternative,""}

  syntax InspectExpression ::= "inspect" "constexpr" Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect" "constexpr" Expression                   "{"              "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect"             Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect"             Expression                   "{"              "}" [seqstrict(parse), hybrid(WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(WellFormed)]



  syntax Statement ::= "let" ParameterDeclarationList Statement                                [seqstrict(parse), hybrid(WellFormed)]
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | Declaration
                     | ExpressionStatement
                     | Contract

  syntax Statements ::= List{Statement,""}                                    [seqstrict(parse), hybrid(WellFormed)]
  syntax CompoundStatement ::= "{" Statements "}"                                              [seqstrict(parse), hybrid(WellFormed)]
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration                               [seqstrict(parse), hybrid(WellFormed)]
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}                              [seqstrict(parse), hybrid(WellFormed)]
  syntax ParameterDeclarationList ::= "(" ParameterDeclarations ")"                            [seqstrict(parse), hybrid(WellFormed)]

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(WellFormed)]
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(WellFormed)]

  syntax ReturnList ::= "->" IdExpression                                                      [seqstrict(parse), hybrid(WellFormed)]
                      | "->" ParameterDeclarationList                                          [seqstrict(parse), hybrid(WellFormed)]

  syntax Contracts ::= List{Contract,""}                                                       [seqstrict(parse), hybrid(WellFormed)]

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts               [seqstrict(parse), hybrid(WellFormed)]
                        | ParameterDeclarationList          ReturnList Contracts               [seqstrict(parse), hybrid(WellFormed)]

  syntax UnnamedDeclaration ::= ":" FunctionType "=" Statement                                 [seqstrict(parse), hybrid(WellFormed)]
                              | ":" IdExpression "=" Statement                                 [seqstrict(parse), hybrid(WellFormed)]
                              | ":"              "=" Statement                                 [seqstrict(parse), hybrid(WellFormed)]
                              | ":" IdExpression                                               [seqstrict(parse), hybrid(WellFormed)]
                              | ":" IdExpression ";"                                           [seqstrict(parse), hybrid(WellFormed)]

  syntax Declaration ::= Identifier UnnamedDeclaration                                         [seqstrict(parse), hybrid(WellFormed)]
  syntax Declarations ::= List{Declaration,""}                                [seqstrict(parse), hybrid(WellFormed)]
  syntax TranslationUnit ::= Declarations 
endmodule
