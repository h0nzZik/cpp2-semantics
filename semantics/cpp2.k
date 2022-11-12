module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

  // based on https://github.com/hsutter/cppfront/blob/main/source/parse.h

  syntax Literal  ::= Int | String

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

  syntax PrimaryExpression ::= Literal
                             | "(" Expressions ")"
                             | IdExpression
                             | UnnamedDeclaration
                             | InspectExpression

  syntax PostfixExpression ::= PrimaryExpression
                             | PostfixExpression PostfixOperator // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"
                             | PostfixExpression "(" Expressions ")"
                             | PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression


  syntax PrefixExpression ::= PostfixExpression
                            | PrefixOperator PrefixExpression

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    | MultiplicativeExpression "*" IsAsExpression
                                    | MultiplicativeExpression "/" IsAsExpression
                                    | MultiplicativeExpression "%" IsAsExpression
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              | AdditiveExpression "+" MultiplicativeExpression 
                              | AdditiveExpression "-" MultiplicativeExpression 


  syntax ShiftExpression ::= AdditiveExpression
                           | ShiftExpression "<<" AdditiveExpression
                           | ShiftExpression ">>" AdditiveExpression

  syntax CompareExpression ::= ShiftExpression
                             | CompareExpression "<=>" ShiftExpression

  syntax RelationalExpression ::= CompareExpression
                                | RelationalExpression "<"  CompareExpression
                                | RelationalExpression ">"  CompareExpression
                                | RelationalExpression "<=" CompareExpression
                                | RelationalExpression ">=" CompareExpression

  syntax EqualityExpression ::= RelationalExpression
                              | EqualityExpression "==" RelationalExpression
                              | EqualityExpression "!=" RelationalExpression

  syntax BitAndExpression ::= EqualityExpression
                            | BitAndExpression "&" EqualityExpression

  syntax BitXorExpression ::= BitAndExpression
                            | BitXorExpression "^" BitAndExpression

  syntax BitOrExpression ::= BitXorExpression
                           | BitOrExpression "|" BitXorExpression

  syntax LogicalAndExpression ::= BitOrExpression
                                | LogicalAndExpression "&&" BitOrExpression


  syntax LogicalOrExpression ::= LogicalAndExpression
                               | LogicalOrExpression "||" LogicalAndExpression

  syntax AssignmentExpression ::= LogicalOrExpression
                                | AssignmentExpression AssignmentOperator AssignmentExpression

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"
                      | Identifier "<"                      ">"

  syntax UnqualifiedId ::= "const" Identifier
                         |         Identifier
                         | "const" TemplateId
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId
                        | MemberNameSpecifier UnqualifiedId

  syntax MemberNameSpecifier ::= UnqualifiedId "."

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"

  syntax IdExpression ::= UnqualifiedId | QualifiedId

  syntax ExpressionStatement ::= Expression ";"
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement
                              | "if"             Expression CompoundStatement
                              | "if" "constexpr" Expression CompoundStatement "else" CompoundStatement
                              | "if"             Expression CompoundStatement "else" CompoundStatement
                              

  syntax ReturnStatement ::= "return" Expression ";"
                           | "return" ";"
 
  syntax IterationStatement ::= "while" LogicalOrExpression NextClause CompoundStatement
                              | "while" LogicalOrExpression            CompoundStatement
                              | "do" CompoundStatement "while" LogicalOrExpression NextClause ";"
                              | "do" CompoundStatement "while" LogicalOrExpression            ";"
                              | "for" Expression NextClause "do" UnnamedDeclaration
                              | "for" Expression            "do" UnnamedDeclaration


  syntax NextClause ::= "next" AssignmentExpression

  syntax IsTypeConstraint ::= "is" IdExpression  

  syntax AsTypeCast ::= "as" IdExpression

  syntax AltName ::= UnqualifiedId ":"

  syntax Alternative ::= AltName IsTypeConstraint "=" Statement
                       | AltName AsTypeCast "=" Statement
                       |         IsTypeConstraint "=" Statement
                       |         AsTypeCast "=" Statement

  syntax Alternatives ::= List{Alternative,""}

  syntax InspectExpression ::= "inspect" "constexpr" Expression                   "{" Alternatives "}" 
                             | "inspect" "constexpr" Expression "->" IdExpression "{" Alternatives "}" 
                             | "inspect" "constexpr" Expression                   "{"              "}" 
                             | "inspect" "constexpr" Expression "->" IdExpression "{"              "}" 
                             | "inspect"             Expression                   "{" Alternatives "}" 
                             | "inspect"             Expression "->" IdExpression "{" Alternatives "}" 
                             | "inspect"             Expression                   "{"              "}" 
                             | "inspect"             Expression "->" IdExpression "{"              "}" 



  syntax Statement ::= "let" ParameterDeclarationList Statement
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | Declaration // TODO check whether this is correct; the spec says "declaration-statement"
                     | ExpressionStatement
                     | Contract

  syntax Statements ::= List{Statement,""}

  syntax CompoundStatement ::= "{" Statements "}"
                             | "{" "}"
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}
  syntax ParameterDeclarationList ::= "(" ")"
                                    | "(" ParameterDeclarations ")"

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]"
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]"

  syntax ReturnList ::= IdExpression ParameterDeclarationList

  syntax Contracts ::= List{Contract,""}

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts
                        | ParameterDeclarationList "throws" ReturnList
                        | ParameterDeclarationList "throws"            Contracts
                        | ParameterDeclarationList "throws"
                        | ParameterDeclarationList          ReturnList Contracts
                        | ParameterDeclarationList          ReturnList
                        | ParameterDeclarationList                     Contracts
                        | ParameterDeclarationList





  syntax UnnamedDeclaration ::= FunctionType "=" Statement
                              | IdExpression "=" Statement
                              | "=" Statement
                              | IdExpression

  syntax Declaration ::= Identifier UnnamedDeclaration
  syntax Declarations ::= List{Declaration,""}
  syntax TranslationUnit ::= Declarations 

endmodule

module CPP2
    imports CPP2-SYNTAX 
    imports DOMAINS

   syntax KItem ::= process(TranslationUnit)

   configuration <T>
                  <threads>
                    <thread type="Set" multiplicity="*">
                      <k> process($PGM) </k>
                      <env> .Map </env>
                      <id> 0 </id>
                    </thread>
                  </threads>
                  <store> .Map </store>
                </T>


    syntax ThreadId ::= threadId(Int)

    syntax KResult ::= Bool | Int | ThreadId

endmodule
