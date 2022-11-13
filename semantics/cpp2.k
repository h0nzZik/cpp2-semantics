module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

  // based on https://github.com/hsutter/cppfront/blob/main/source/parse.h

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

  syntax Statements ::= List{Statement,""} [seqstrict(c)]

  syntax CompoundStatement ::= "{" Statements "}"
  
  syntax ThisSpecifier ::= "implicit" | "virtual" | "override" | "final"

  syntax ParameterDirection ::= "in" | "copy" | "inout" | "out" | "move" | "forward"

  syntax ParameterDeclaration ::= ParameterDirection Declaration
                                | Declaration

  syntax ParameterDeclarations ::= List{ParameterDeclaration,","}
  syntax ParameterDeclarationList ::= "(" ParameterDeclarations ")"

  syntax ContractKind ::= "pre" | "post" | "assert"

  syntax Contract ::= "[" "[" ContractKind IdExpression LogicalOrExpression "]" "]"
                    | "[" "[" ContractKind IdExpression LogicalOrExpression "," String "]" "]"
                    | "[" "[" ContractKind              LogicalOrExpression "]" "]"
                    | "[" "[" ContractKind              LogicalOrExpression "," String "]" "]"

  syntax ReturnList ::= "->" IdExpression
                      | "->" ParameterDeclarationList

  syntax Contracts ::= List{Contract,""}

  syntax FunctionType ::= ParameterDeclarationList "throws" ReturnList Contracts
                        | ParameterDeclarationList          ReturnList Contracts





  syntax UnnamedDeclaration ::= ":" FunctionType "=" Statement
                              | ":" IdExpression "=" Statement
                              | ":"              "=" Statement
                              | ":" IdExpression

  syntax Declaration ::= Identifier UnnamedDeclaration
  syntax Declarations ::= List{Declaration,""}
  syntax TranslationUnit ::= Declarations 

endmodule

module CPP2
  imports CPP2-SYNTAX 
  imports DOMAINS

  syntax Phase ::= TranslationPhase() | ExecutionPhase()
  syntax TranslateResult
  syntax ExecResult

  context alias [c]: <k> HERE:K ... </k> <phase> TranslationPhase() </phase> [result(TranslateResult)]
  context alias [c]: <k> HERE:K ... </k> <phase> ExecutionPhase() </phase> [result(ExecResult)]


  // Notation : ${SortName}C is the sort of basic constructors representing values of the sort ${SortName}.
  // It should always be true that `ExecResult ::= ${SortName}C`
  // Similarly, ${SortName}F is the sort of function-like constructors representing operations of the sort ${SortName}.
  // From K's perspective, both are constructors and not functions.

  syntax ObjectIDC ::= objectID(Int)
  syntax ObjectIDF ::= lookupObjectID(Identifier)
  syntax ObjectID ::= ObjectIDC | ObjectIDF
  syntax ExecResult ::= ObjectIDC

  syntax ValueC ::= boolValue(Bool) | intValue(Int) | voidValue()
  syntax ValueF ::= readValue(ObjectID)
                  | Expression
  syntax Value ::= ValueC | ValueF
  syntax ExecResult ::= ValueC

  configuration <T>
                  <phase> TranslationPhase() </phase>
                  <k> $PGM:TranslationUnit </k>
                  <declarations> .Map </declarations>
                  <state>
                    <stack> .List </stack>
                    <local>
                      <blocks> .List </blocks>
                      <returnVariables> .Map </returnVariables> // Identifier |-> ObjectIDC
                    </local>
                    <memory> .Map </memory> // Int |-> Value (the key represents ObjectIDC)
                  </state>
                  <exit-code exit=""> 139 </exit-code>
                </T>

  // Memory
  //------------------------------------------------------
  syntax KItem ::= writeValue(ObjectID, Value) [seqstrict(c)]

  rule <k> writeValue(objectID(I), V) => .K ...</k>
       <memory> M => M [ I <- V ] </memory>

  rule <k> readValue(objectID(I)) => V ...</k>
       <memory>... I |-> V ...</memory>

  // Names
  //-----------------------------------------------------
  rule <k> lookupObjectID(X) => ID ...</k>
       <returnVariables>... (X |-> ID:ObjectIDC) ...</returnVariables>


  rule <k> D:Declaration Ds:Declarations => D ~> Ds </k>

  rule <k> (X:Identifier UD:UnnamedDeclaration):Declaration => .K ...</k>
       <declarations>... .Map => (X |-> UD) ...</declarations>

  syntax KItem ::= callMain()

  rule <k> .Declarations => callMain() </k>
       <phase> TranslationPhase() => ExecutionPhase() </phase>


  syntax KResult ::= ExecResult

  // Execution phase
  
  rule callMain() => callFunction(main) ~> implicitReturn(0)
  
  syntax Id ::= "main" [token]
  syntax KItem ::= callFunction(Identifier)

  syntax StackFrame ::= stackFrame(cont: K, blocks: List, retvars: Map)
  syntax BlockFrame ::= blockFrame()

  rule [call-function]:
       <k> (callFunction(F:Identifier) ~> Rest:K) => S </k>
       <declarations>... F |-> ( : _T:FunctionType = S:Statement):UnnamedDeclaration ...</declarations>
       <stack>... (.List => ListItem(stackFrame(Rest, Blocks, RVs))) </stack>
       <blocks> Blocks:List => .List </blocks>
       <returnVariables> RVs => (unnamedReturnVariable() |-> objectID(!_I:Int)) </returnVariables>


  syntax KItem ::= implicitReturn(Expression) [seqstrict(c)]

  rule <k> ({ Stmts:Statements }):CompoundStatement => enterBlock() ~> Stmts ~> leaveBlock() ...</k> 

  syntax KItem ::= enterBlock() | leaveBlock()

  rule <k> enterBlock() => .K ...</k>
       <blocks>... (.List => ListItem(blockFrame())) </blocks>
       
  rule <k> leaveBlock() => .K ...</k>
       <blocks>... (ListItem(blockFrame()) => .List) </blocks>

  syntax Identifier ::= unnamedReturnVariable()

  rule [return-exp]:
    return E:Expression ; => returnValue(evaluateExpression(E))
  
  syntax ValueF ::= evaluateExpression(Expression) [seqstrict(c)]

  rule evaluateExpression(V:Int) => intValue(V)
  //rule evaluateExpression(V:Bool) => boolValue(V)

  syntax KItem ::= returnValue(Value) [seqstrict(c)]

  rule [return-value]:
    returnValue(V:ValueC)
    => writeValue(lookupObjectID(unnamedReturnVariable()), V)
    ~> return ;

  // TODO
  //rule <k> return ; =>  ...</k>

endmodule
