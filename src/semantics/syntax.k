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
                             | "(" Expressions ")"                                                   [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | UnnamedDeclaration

  syntax PostfixExpression ::= PrimaryExpression
                             | PostfixExpression PostfixOperator  [seqstrict(parse), hybrid(IllFormed, WellFormed)] // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"  [seqstrict(parse), hybrid(IllFormed, WellFormed)] // TODO nonempty list of expressions
                             | PostfixExpression "(" Expressions ")"                                  [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             //| PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression                                     [seqstrict(parse), hybrid(IllFormed, WellFormed)]


  syntax PrefixExpression ::= PostfixExpression
                            | PrefixOperator PrefixExpression                                         [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    | MultiplicativeExpression "*" IsAsExpression                      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                    | MultiplicativeExpression "/" IsAsExpression                      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                    | MultiplicativeExpression "%" IsAsExpression                      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              | AdditiveExpression "+" MultiplicativeExpression                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | AdditiveExpression "-" MultiplicativeExpression                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]


  syntax ShiftExpression ::= AdditiveExpression
                           | ShiftExpression "<<" AdditiveExpression                                   [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                           | ShiftExpression ">>" AdditiveExpression                                   [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax CompareExpression ::= ShiftExpression
                             | CompareExpression "<=>" ShiftExpression                                 [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax RelationalExpression ::= CompareExpression
                                | RelationalExpression "<"  CompareExpression                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression ">"  CompareExpression                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression "<=" CompareExpression                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                | RelationalExpression ">=" CompareExpression                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax EqualityExpression ::= RelationalExpression
                              | EqualityExpression "==" RelationalExpression                           [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | EqualityExpression "!=" RelationalExpression                           [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax BitAndExpression ::= EqualityExpression
                            | BitAndExpression "&" EqualityExpression                                  [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax BitXorExpression ::= BitAndExpression
                            | BitXorExpression "^" BitAndExpression                                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax BitOrExpression ::= BitXorExpression
                           | BitOrExpression "|" BitXorExpression                                      [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax LogicalAndExpression ::= BitOrExpression
                                | LogicalAndExpression "&&" BitOrExpression                            [seqstrict(parse), hybrid(IllFormed, WellFormed)]


  syntax LogicalOrExpression ::= LogicalAndExpression
                               | LogicalOrExpression "||" LogicalAndExpression                         [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax AssignmentExpression ::= LogicalOrExpression
  //                              | AssignmentExpression AssignmentOperator AssignmentExpression
  //                            | AssignmentExpression AssignmentOperator LogicalOrExpression          [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}                                                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}                                           [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"                                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax UnqualifiedId ::= "const" Identifier                                                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                         |         Identifier
                         | "const" TemplateId                                                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId                                             [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                        | MemberNameSpecifier UnqualifiedId                                            [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax MemberNameSpecifier ::= UnqualifiedId "."                                                     [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"                                                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax IdExpression ::= QualifiedId    [hybrid(IllFormed)]
                        > UnqualifiedId  [hybrid(IllFormed)]

  syntax ExpressionStatement ::= Expression ";"                                                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "if"             Expression CompoundStatement                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "if" "constexpr" Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "if"             Expression CompoundStatement "else" CompoundStatement [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              

  syntax ReturnStatement ::= "return" Expression ";"                                                   [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                           | "return" ";"
 
  syntax IterationStatement ::= "while" LogicalOrExpression NextClause CompoundStatement               [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "while" LogicalOrExpression            CompoundStatement               [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression NextClause ";"      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "do" CompoundStatement "while" LogicalOrExpression            ";"      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "for" Expression NextClause "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | "for" Expression            "do" UnnamedDeclaration                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]


  syntax NextClause ::= "next" AssignmentExpression                                                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax IsTypeConstraint ::= "is" IdExpression                                                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax AsTypeCast ::= "as" IdExpression                                                              [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax AltName ::= UnqualifiedId ":"                                                                 [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax Alternative ::= AltName IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                       | AltName AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                       |         IsTypeConstraint "=" Statement                                        [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                       |         AsTypeCast "=" Statement                                              [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax Alternatives ::= List{Alternative,""}

  syntax InspectExpression ::= "inspect" "constexpr" Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression                   "{"              "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect" "constexpr" Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression                   "{" Alternatives "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{" Alternatives "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression                   "{"              "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                             | "inspect"             Expression "->" IdExpression "{"              "}" [seqstrict(parse), hybrid(IllFormed, WellFormed)]



  syntax Statement ::= "let" ParameterDeclarationList Statement                                [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | Declaration
                     | ExpressionStatement
                     | Contract

  syntax Statements ::= List{Statement,""}                                    [seqstrict(parse), hybrid(IllFormed, WellFormed)]
  syntax CompoundStatement ::= "{" Statements "}"                                              [seqstrict(parse), hybrid(IllFormed, WellFormed)]
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration                               [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}                              [seqstrict(parse), hybrid(IllFormed, WellFormed)]
  syntax ParameterDeclarationList ::= "(" ParameterDeclarations ")"                            [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"            [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]" [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax ReturnList ::= "->" IdExpression                                                      [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                      | "->" ParameterDeclarationList                                          [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax Contracts ::= List{Contract,""}                                                       [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts               [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                        | ParameterDeclarationList          ReturnList Contracts               [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax UnnamedDeclaration ::= ":" FunctionType "=" Statement                                 [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | ":" IdExpression "=" Statement                                 [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | ":"              "=" Statement                                 [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | ":" IdExpression                                               [seqstrict(parse), hybrid(IllFormed, WellFormed)]
                              | ":" IdExpression ";"                                           [seqstrict(parse), hybrid(IllFormed, WellFormed)]

  syntax Declaration ::= Identifier UnnamedDeclaration                                         [seqstrict(parse), hybrid(IllFormed, WellFormed)]
  syntax Declarations ::= List{Declaration,""}                                [seqstrict(parse), hybrid(IllFormed, WellFormed)]
  syntax TranslationUnit ::= Declarations 
endmodule
