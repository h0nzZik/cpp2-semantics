module CPP2-SYNTAX
  imports DOMAINS-SYNTAX

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
                             > IdExpression
                             > Literal
                             > "(" Expressions ")" 
                             > UnnamedDeclaration

  syntax PostfixExpression ::= PrimaryExpression
                             > PostfixExpression PostfixOperator // TODO: without whitespace
                             | PostfixExpression "[" Expressions "]"
                             | PostfixExpression "(" Expressions ")"
                             //| PostfixExpression "(" ")"
                             | PostfixExpression "." IdExpression


  syntax PrefixExpression ::= PostfixExpression
                            > PrefixOperator PrefixExpression

  syntax IsAsExpression ::= PrefixExpression
//                          | IsAsExpression IsExpressionConstraint
//                          | IsAsExpression AsTypeCast
                          

  syntax MultiplicativeExpression ::= IsAsExpression
                                    > MultiplicativeExpression "*" IsAsExpression
                                    | MultiplicativeExpression "/" IsAsExpression
                                    | MultiplicativeExpression "%" IsAsExpression
 
  syntax AdditiveExpression ::= MultiplicativeExpression
                              > AdditiveExpression "+" MultiplicativeExpression 
                              | AdditiveExpression "-" MultiplicativeExpression 


  syntax ShiftExpression ::= AdditiveExpression
                           > ShiftExpression "<<" AdditiveExpression
                           | ShiftExpression ">>" AdditiveExpression

  syntax CompareExpression ::= ShiftExpression
                             > CompareExpression "<=>" ShiftExpression

  syntax RelationalExpression ::= CompareExpression
                                > RelationalExpression "<"  CompareExpression
                                | RelationalExpression ">"  CompareExpression
                                | RelationalExpression "<=" CompareExpression
                                | RelationalExpression ">=" CompareExpression

  syntax EqualityExpression ::= RelationalExpression
                              > EqualityExpression "==" RelationalExpression
                              | EqualityExpression "!=" RelationalExpression

  syntax BitAndExpression ::= EqualityExpression
                            > BitAndExpression "&" EqualityExpression

  syntax BitXorExpression ::= BitAndExpression
                            > BitXorExpression "^" BitAndExpression

  syntax BitOrExpression ::= BitXorExpression
                           > BitOrExpression "|" BitXorExpression

  syntax LogicalAndExpression ::= BitOrExpression
                                > LogicalAndExpression "&&" BitOrExpression


  syntax LogicalOrExpression ::= LogicalAndExpression
                               > LogicalOrExpression "||" LogicalAndExpression

  syntax AssignmentExpression ::= LogicalOrExpression
  //                              | AssignmentExpression AssignmentOperator AssignmentExpression
                                > AssignmentExpression AssignmentOperator LogicalOrExpression [expressionStatementTag]

  syntax Expression ::= AssignmentExpression

  syntax Expressions ::= List{Expression,","}
 
  syntax TemplateArgument ::= Expression | IdExpression

  syntax TemplateArgumentList ::= List{TemplateArgument,","}

  syntax TemplateId ::= Identifier "<" TemplateArgumentList ">"

  syntax UnqualifiedId ::= "const" Identifier
                         |         Identifier
                         | "const" TemplateId
                         |         TemplateId

  syntax QualifiedId ::= NestedNameSpecifier UnqualifiedId
                        | MemberNameSpecifier UnqualifiedId

  syntax MemberNameSpecifier ::= UnqualifiedId "."

  syntax NestedNameSpecifier ::= "::"
                               | UnqualifiedId "::"

  syntax IdExpression ::= QualifiedId
                        > UnqualifiedId

  syntax ExpressionStatement ::= Expression ";"
                               > Expression 

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
                     > SelectionStatement
                     > InspectExpression
                     > ReturnStatement
                     > IterationStatement
                     > CompoundStatement
                     > Declaration        //[klabel(lblDeclaration), symbol]
                     > ExpressionStatement //[klabel(lblExpressionStmt), symbol]
                     > Contract

  syntax Statements ::= NeList{Statement,""} [seqstrict(c)]

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
  syntax ExecResult ::= Int | String | Bool
  syntax KResult ::= ExecResult

  context alias [c]: <k> HERE:K ... </k> <phase> TranslationPhase() </phase> [result(TranslateResult)]
  context alias [c]: <k> HERE:K ... </k> <phase> ExecutionPhase() </phase> [result(ExecResult)]


  // Convention: Separate sorts for operations and data
  // This sort represents various data, typically stored as values in maps and lists.
  // There are no rules rewriting these.
  // Also, these never get to the top of the K cell 
  syntax Record
  // And this one represents operations.
  // Usually, there is one or more rules that manipulate this when it appears on top of the K cell.
  // Usually, operations perform some side effect on the configuration,
  // and at the end, they always rewrite to [.K].
  syntax Operation
  // But both are just plain KItems
  syntax KItem ::= Record | Operation

  // Notation : ${SortName}C is the sort of basic constructors representing values of the sort ${SortName}.
  // It should always be true that `ExecResult ::= ${SortName}C`
  // Similarly, ${SortName}F is the sort of function-like constructors representing operations of the sort ${SortName}.
  // From K's perspective, both are constructors and not functions.

  syntax ObjectIDC ::= objectID(Int)
  syntax ObjectIDF ::= lookupObjectID(Identifier)
  syntax ObjectID ::= ObjectIDC | ObjectIDF
  syntax ExecResult ::= ObjectIDC

  // We use bool values in both translation and execution
  // Therefore, we need KResult ::= BoolValueC
  // and constructors of sort [BoolValueF] should use normal context
  // (that is, they should *not* use the context alias [c] defined above).
  syntax BoolValueC ::= boolValue(Bool)
  syntax BoolValueF
  syntax BoolValue ::= BoolValueC | BoolValueF
  syntax KResult ::= BoolValueC

  syntax ValueC ::= BoolValueC | intValue(Int) | voidValue()
  syntax ValueF ::= readValue(ObjectID)
                  | Expression
  syntax Value ::= ValueC | ValueF
  syntax ExecResult ::= ValueC

  configuration <T>
                  <phase> TranslationPhase() </phase>
                  <k> $PGM:TranslationUnit </k>
                  <global-function-declarations> .Map </global-function-declarations>
                  <global-variable-declarations> .Map </global-variable-declarations>
                  <translation-state>
                    // We need these lists on order to perform deterministic traversal of the map
                    <global-function-declarations-list> .List </global-function-declarations-list>
                    <global-variable-declarations-list> .List </global-variable-declarations-list>
                  </translation-state>
                  <execution-state>
                    <stack> .List </stack>
                    <local>
                      <blocks> .List </blocks>
                      <returnVariables> .Map </returnVariables> // Identifier |-> ObjectIDC
                    </local>
                    <global-variables> .Map </global-variables> // Identifier |-> ObjectIDC
                    <memory> .Map </memory> // Int |-> Value (the key represents ObjectIDC)
                  </execution-state>
                  <exit-code exit=""> 139 </exit-code>
                </T>

  // TODO move this to the execution section
  // Memory
  //------------------------------------------------------
  syntax Operation ::= writeValue(ObjectID, Value) [seqstrict(c)]

  rule <k> writeValue(objectID(I), V) => .K ...</k>
       <memory> M => M [ I <- V ] </memory>

  rule <k> readValue(objectID(I)) => V ...</k>
       <memory>... I |-> V ...</memory>

  // Names
  //-----------------------------------------------------
  rule <k> lookupObjectID(X) => ID ...</k>
       <returnVariables>... (X |-> ID:ObjectIDC) ...</returnVariables>


  rule <k> D:Declaration Ds:Declarations => declareGlobal(D) ~> Ds </k>

  // Declares a global variable or a function
  syntax Operation ::= declareGlobal(Declaration)

  rule declareGlobal(X:Identifier : FT:FunctionType = Stmt:Statement)
    => declareGlobalFunction(X, FT, elaborateFunctionBody(Stmt))

  // Represents function bodies
  syntax FunctionBodyC ::= functionBody(Statement)
  syntax FunctionBodyF ::= elaborateFunctionBody(Statement)
  syntax FunctionBody ::= FunctionBodyC | FunctionBodyF
  syntax TranslateResult ::= FunctionBodyC


  syntax Operation ::= declareGlobalFunction(Identifier, FunctionType, FunctionBody) [seqstrict(c;3)]

  rule <k> declareGlobalFunction(X:Identifier, FT:FunctionType, B:FunctionBody) => .K ...</k>
     <global-function-declarations>... .Map => (X |-> globalFunction(X, FT, B)) ...</global-function-declarations>
     <global-function-declarations-list>... (.List => ListItem(X)) </global-function-declarations-list>

  // Represent a declared function, where the body has been already elaborated.
  syntax Record ::= globalFunction(id: Identifier, type: FunctionType, body: FunctionBody)

  // TODO implement various passes through the statement
  rule elaborateFunctionBody(S) => functionBody(S)

  // What we have to do when processing a function (anonymous or not)?
  // 2. name lookup
  // 3. analyze first and last uses of local variables and parameters.
  // How should name lookup work?
  // First, check whether a name belongs to a block variable.
  // If not, check whether it is a parameter of the function.
  // If not, assume it is a global variable.
  // Note that we cannot check whether it is a global variable or not in the first phase of the translation semantics,
  // because at that point, some global variables (like those defined later in the source) are not yet visible.
  // Theoretically, we could first declare all global functions by moving them to the <global-function-declarations> cell,
  // and only afterwords we would process their bodies; however, the declarations cell is a map,
  // and processing it element-by-element would bring nondeterminism into the play.
  // So what we can do instead, is that after everything is declared, then we could go through the bodies
  // and only check that the names that we thing are global, are really global.
  // And only after that we would execute the program.


  // Execution phase

  syntax Operation ::= programStartup()

  rule <k> .Declarations => programStartup() </k>
       <phase> TranslationPhase() => ExecutionPhase() </phase>

  rule programStartup()
     => instantiateGlobalVariables()
     ~> callFunction(main)
     ~> exitWithValue()

  syntax Operation ::= instantiateGlobalVariables()

  rule instantiateGlobalVariables() => .K

  syntax Operation ::= exitWithValue()
  rule <k> (intValue(X) ~> exitWithValue()) ~> _ => .K </k>
       <exit-code> _ => X </exit-code>
  
  rule <k> (voidValue() ~> exitWithValue()) ~> _ => .K </k>
       <exit-code> _ => 0 </exit-code>
  
  syntax Id ::= "main" [token]
  syntax Operation ::= callFunction(Identifier)

  syntax StackFrame ::= stackFrame(cont: K, blocks: List, retvars: Map)
  syntax BlockFrame ::= blockFrame()

  rule [call-function]:
       <k> (callFunction(F:Identifier) ~> Rest:K) => writeValue(objectID(!I:Int), voidValue()) ~> S </k>
       <global-function-declarations>... F |-> ( : _T:FunctionType = S:Statement):UnnamedDeclaration ...</global-function-declarations>
       <stack>... (.List => ListItem(stackFrame(Rest, Blocks, RVs))) </stack>
       <blocks> Blocks:List => .List </blocks>
       <returnVariables> RVs => (unnamedReturnVariable() |-> objectID(!I:Int)) </returnVariables>

  rule [compound-nonempty]: <k> ({ Stmts:Statements }):CompoundStatement => enterBlock() ~> Stmts ~> leaveBlock() ...</k> 
  //rule [compound-empty]: <k> ({ }):CompoundStatement => enterBlock() ~> leaveBlock() ...</k> 

  syntax Operation ::= enterBlock() | leaveBlock()

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

  syntax Operation ::= returnValue(Value) [seqstrict(c)]

  rule [return-value]:
    returnValue(V:ValueC)
    => writeValue(lookupObjectID(unnamedReturnVariable()), V)
    ~> return ;

  rule [return-from-block]:
       <k> (.K => leaveBlock()) ~> return ; ...</k>
       <blocks>... ListItem(_) </blocks>

  rule [return-no-block]:
       <k> return ; => readValue(objectID(I)) ~> Rest...</k>
       <blocks> .List  => Blocks</blocks>
       <stack>... (ListItem(stackFrame(Rest, Blocks, RVs)) => .List) </stack>
       <returnVariables> (unnamedReturnVariable() |-> objectID(I:Int)) => RVs </returnVariables>

  // A conditional / branching operation
  syntax Operation ::= ite(BoolValue, Operation, Operation) [strict(1)]

  rule [ite-true]: ite(boolValue(true), X, _Y) => X
  rule [ite-false]: ite(boolValue(false), _X, Y) => Y

  // Are those two value categories enough for the simplified language?
  // Also, we query on value categories in translation time
  syntax ValueCategoryC ::= lvalue() | rvalue()
  syntax ValueCategoryF ::= valueCategoryOf(Expression) [seqstrict(c)]
  syntax ValueCategory ::= ValueCategoryC | ValueCategoryF
  syntax TranslateResult ::= ValueCategoryC

  // I think this is not true, because it depends on whether the identifier is an in/out parameter
  // See https://github.com/hsutter/708/blob/main/708.pdf
  rule valueCategoryOf(_X:Identifier) => lvalue()
  rule valueCategoryOf(_) => rvalue()

endmodule
