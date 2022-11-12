module PRESSY-SYNTAX
  imports DOMAINS-SYNTAX

  syntax DExp  ::= Int | String | Id

  syntax Identifier

  syntax AssignmentExpression ::= LogicalOrExpression
                                | AssignmentExpression AssignmentOperator AssignmentExpression

  syntax Expression ::= AssignmentExpression

  syntax ExpressionList ::= List{Expression,","}
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"
                      | Identifier "<"                      ">"

  syntax UnqualifiedId ::= "const" Identifier
                         |         Identifier
                         | "const" TemplateId
                         |         TemplateId

  syntax QuanlifiedId ::= NestedNameSpecifier UnqualifiedId
                        | MemberNameSpecifier UnqualifiedId

  syntax MemberNameSpecifier ::= UnqualifiedId "."

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"

  syntax IdExpression ::= UnqualifiedId | QualifiedId

  syntax ExpressionStatement ::= Expression ";"
                               | Expression

  syntax SelectionStatement ::= "if" "constexpr" Expression CompoundStatement
                              | "if"             Expression CompoundStatement
                              | "if" "constexpr" Expression CompoundStatement "else" CoompoundStatement
                              | "if"             Expression CompoundStatement "else" CoompoundStatement
                              

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



  syntax Statement ::= "let" ParameterList Statement
                     | SelectionStatement
                     | InspectExpression
                     | ReturnStatement
                     | IterationStatement
                     | CompoundStatement
                     | DeclarationStatement
                     | ExpressionStatement
                     | Contract

  syntax CompoundStatement ::= "{" Statements "}"
                             | "{" "}"
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}
  syntax ParameterDeclarationList ::= "(" ")"
                                    | "(" ParameterDeclarations ")"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalExpression "]" "]"
                    | "[" "[" ContractKind IdExpression LogicalExpression "," String "]" "]"
                    | "[" "[" ContractKind              LogicalExpression "]" "]"
                    | "[" "[" ContractKind              LogicalExpression "," String "]" "]"

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

module PRESSY
    imports PRESSY-SYNTAX 
    imports DOMAINS

   configuration <T>
                  <threads>
                    <thread type="Set" multiplicity="*">
                      <k> $PGM:Stmts </k>
                      <env> .Map </env>
                      <id> 0 </id>
                    </thread>
                  </threads>
                  <store> .Map </store>
                </T>


    syntax ThreadId ::= threadId(Int)

    syntax KResult ::= Bool | Int | ThreadId

endmodule
