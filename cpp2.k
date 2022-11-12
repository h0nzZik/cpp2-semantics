module PRESSY-SYNTAX
    imports DOMAINS-SYNTAX

    // We have two kinds of expressions 'Data' expressions (DExp)
    // and 'boolean' expressions (Bexp)

    syntax DExp  ::= Int | String | Id
                 | "-" DExp                   [strict]
                 | "(" DExp ")"               [bracket]
                 > DExp "/" DExp              [left, seqstrict]
                 > DExp "+" DExp              [left, seqstrict]
                 > "spawn" Block
  syntax BExp  ::= Bool
                 | DExp "==" DExp             [seqstrict]
                 | DExp "<" DExp             [seqstrict]
                 | DExp "<=" DExp             [seqstrict]
                 | DExp ">" DExp             [seqstrict]
                 | DExp ">=" DExp             [seqstrict]
                 | "!" BExp                   [seqstrict]
                 | "(" BExp ")"               [bracket]
                 > BExp "&&" BExp             [left, strict(1)]
  syntax Block ::= "{" Stmts "}"
  syntax Stmt  ::= Block
                 | DExp ";"                   [strict]
                 | "if" "(" BExp ")"
                   Block "else" Block         [strict(1)]
                 | "while" "(" BExp ")" Block
                 | "int" Ids ";"
                 | "halt" ";"
                 > "join" DExp ";"            [strict]

  syntax Ids   ::= List{Id,","}
  syntax Stmts ::= List{Stmt,""}
  syntax AExps ::= Ids


  syntax Identifier

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
