requires "syntax.k"

module CPP2-PHASE
    syntax Phase ::= TranslationPhase() | ExecutionPhase()
endmodule

module ASTNODE
  imports CPP2-SYNTAX 

  syntax PrimaryExpression ::= parentheses(Expressions) [seqstrict(c), symbol, klabel(parentheses)]

  syntax KItem
  // Represents an AST node
  syntax NodeC ::= node(KItem)
  syntax NodeF
  syntax Node ::= NodeC | NodeF
  syntax TranslateResult ::= NodeC
  syntax NodeC

  // Generalize the AST so that NodeC can be plugged anywhere in it
  syntax PrimaryExpression ::= Node
  syntax PostfixExpression ::= Node
  syntax PrefixExpression ::= Node
  syntax IsAsExpression ::= Node
  syntax MultiplicativeExpression ::= Node 
  syntax AdditiveExpression ::= Node
  syntax ShiftExpression ::= Node
  syntax CompareExpression ::= Node
  syntax RelationalExpression ::= Node
  syntax EqualityExpression ::= Node
  syntax BitAndExpression ::= Node
  syntax BitXorExpression ::= Node
  syntax BitOrExpression ::= Node
  syntax LogicalAndExpression ::= Node
  syntax LogicalOrExpression ::= Node
  syntax AssignmentExpression ::= Node
  syntax Expression ::= Node
  syntax Expressions ::= Node 
  syntax TemplateArgument ::= Node
  syntax TemplateArgumentList ::= Node
  syntax TemplateId ::= Node
  syntax UnqualifiedId ::= Node
  syntax QualifiedId ::= Node
  syntax MemberNameSpecifier ::= Node
  syntax NestedNameSpecifier ::= Node
  syntax IdExpression ::= Node
  syntax ExpressionStatement ::= Node
  syntax SelectionStatement ::= Node
  syntax ReturnStatement ::= NodeC
  syntax IterationStatement ::= Node
  syntax NextClause ::= Node
  syntax IsTypeConstraint ::= Node
  syntax AsTypeCast ::= Node
  syntax AltName ::= Node
  syntax Alternative ::= Node
  syntax Alternatives ::= Node
  syntax InspectExpression ::= Node
  syntax Statement ::= Node
  syntax Statements ::= Node
  syntax CompoundStatement ::= Node
  syntax ParameterDeclaration ::= Node
  syntax ParameterDeclarations ::= Node
  syntax ParameterDeclarationList ::= Node
  syntax Contract ::= Node
  syntax ReturnList ::= Node
  syntax Contracts ::= Node
  syntax FunctionType ::= Node
  syntax UnnamedDeclaration ::= Node
  syntax Declaration ::= Node
  syntax Declarations ::= Node
  syntax TranslationUnit ::= Node
endmodule

module CPP2
  imports DOMAINS
  imports ASTNODE
  imports CPP2-PHASE
  // Modules for verification
  imports MAP-SYMBOLIC
  imports INT-SYMBOLIC
  imports ML-SYNTAX

  syntax Id ::= String2Idmacro (String) [macro,function, total, hook(STRING.string2token)]

  syntax TranslateResult
  syntax ExecResult ::= Int | String | Bool
  syntax KResult ::= ExecResult


  // TODO: create context for this production
  // syntax Statements ::= NeList{Statement,""} [seqstrict(c)]

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
                  <phase parser="PHASE, CPP2-PHASE"> $PHASE:Phase </phase>
                  <k> initialize($PGM:KItem) </k>
                  <translation-result>
                    <global-function-declarations> .Map </global-function-declarations>
                    <global-variable-declarations> .Map </global-variable-declarations>
                  </translation-result>
                  <various-states>
                    <translation-state multiplicity="?">
                      // We need these lists on order to perform deterministic traversal of the map,
                      // in translation time. But we do not need these to perform execution.
                      // Therefore, the whole cell <translation-state> will get stripped in execution.
                      <global-function-declarations-list> .List </global-function-declarations-list>
                      <global-variable-declarations-list> .List </global-variable-declarations-list>

                      <local-variable-names> .Set </local-variable-names>
                    </translation-state>
                    <execution-state multiplicity="?">
                      // This is probably the place to introduce <thread-local>.
                      // But the K cell should stay outside <execution-state>,
                      // because we want it also in translation.
                      // Therefore, we will wrap it in <threads> (eventually).
                      <stack> .List </stack>
                      <local>
                        <blocks> .List </blocks>
                        <returnVariables> .Map </returnVariables> // Identifier |-> ObjectIDC
                      </local>
                      <global-variables> .Map </global-variables> // Identifier |-> ObjectIDC
                      <memory> .Map </memory> // Int |-> Value (the key represents ObjectIDC)
                      <objectid-counter> 0 </objectid-counter>
                    </execution-state>
                  </various-states>
                  <exit-code exit=""> 139 </exit-code>
                </T>

  //context alias [c]: <k> translate(HERE:K) ... </k> <phase> TranslationPhase() </phase> [result(TranslateResult)]

  syntax KItem ::= initialize(KItem)

  // Start the translation phase
  rule <k> initialize(TU:TranslationUnit) => translate(TU) ...</k>
       <phase> TranslationPhase() </phase>
       <various-states> .Bag =>
         <translation-state>
           <global-function-declarations-list> .List </global-function-declarations-list>
           <global-variable-declarations-list> .List </global-variable-declarations-list>
           <local-variable-names> .Set </local-variable-names>
         </translation-state>
       </various-states>


  // We have finished the translation phase
  rule <k> translate(.Declarations) => .K </k>
       <phase> TranslationPhase() </phase>
       <exit-code> _ => 0 </exit-code>
       <various-states> 
         <translation-state> _Ignore </translation-state> => .Bag
       </various-states>

  syntax Operation ::= translate(KItem)

  rule <k> translate(D:Declaration Ds:Declarations) => declareGlobal(D) ~> translate(Ds) </k>

  // Declares a global variable or a function
  syntax Operation ::= declareGlobal(Declaration)

  rule declareGlobal(X:Identifier : FT:FunctionType = Stmt:Statement)
    => declareGlobalFunction(X, FT, elaborateFunctionBody(Stmt))

  // Represents function bodies
  syntax FunctionBodyC ::= functionBody(Statement)
  syntax FunctionBodyF ::= elaborateFunctionBody(KItem)
  syntax FunctionBody ::= FunctionBodyC | FunctionBodyF
  syntax TranslateResult ::= FunctionBodyC


  syntax Operation ::= declareGlobalFunction(Identifier, FunctionType, FunctionBody) // [seqstrict(c;3)]

  context declareGlobalFunction(_,_,HOLE:FunctionBody) [result(FunctionBodyC)]

  rule <k> declareGlobalFunction(X:Identifier, FT:FunctionType, B:FunctionBodyC) => .K ...</k>
     <global-function-declarations>... .Map => (X |-> globalFunction(X, FT, B)) ...</global-function-declarations>
     <global-function-declarations-list>... (.List => ListItem(X)) </global-function-declarations-list>

  // Represent a declared function, where the body has been already elaborated.
  syntax Record ::= globalFunction(id: Identifier, type: FunctionType, body: FunctionBody)

  // TODO implement various passes through the statement
  //rule elaborateFunctionBody(S) => functionBody(S)

  // without the [symbol] annotation, `kompile` crashes when processing the context alias.
  syntax NodeF ::= lookupVariableOccurrences(KItem) 

  context <k> elaborateFunctionBody(HOLE => lookupVariableOccurrences(HOLE)) ...</k> [result(NodeC)]
  rule elaborateFunctionBody(node(X:Statement)) => functionBody(X)

  rule <k> lookupVariableOccurrences(X)
        => lookupVariableOccurrences0(X)
        ~> restoreLocalVariableNames(Names)
        ...</k>
       <local-variable-names> Names => .Set </local-variable-names>
       requires notBool isNodeC(X)

  syntax KItem ::= restoreLocalVariableNames(Set) [private]

  rule <k> (lookupVariableOccurrences0(X:NodeC) ~> restoreLocalVariableNames(Names)) => lookupVariableOccurrences(X) ...</k>
       <local-variable-names> _ => Names </local-variable-names>


  syntax NodeF ::= lookupVariableOccurrences0(KItem) [symbol]

  rule lookupVariableOccurrences0(X:Int => node(X))
  
  context lookupVariableOccurrences0(return (HOLE:Expression) => (lookupVariableOccurrences0(HOLE)) ; )
    [result(NodeC)]
  
  rule lookupVariableOccurrences0(return node(X) ; => node (return X ;))
  
  context lookupVariableOccurrences0((((HOLE:Statement) => (lookupVariableOccurrences0(HOLE))):Statement _:Statements):Statements)
    [result(NodeC)]
  
  context lookupVariableOccurrences0((_:NodeC ((HOLE:Statements) => (lookupVariableOccurrences0( HOLE )))):Statements)
    [result(NodeC)]

  rule lookupVariableOccurrences0((.Statements):Statements => (node(.Statements):Statements))
  
  rule lookupVariableOccurrences0((((node(X:Statement):Statement) (node(XS:Statements):Statements)):Statements) => (node((X XS):Statements):Statements))

  context <k> lookupVariableOccurrences0(({ (HOLE:Statements) => (lookupVariableOccurrences0(HOLE)) }):CompoundStatement) ...</k>
    [result(NodeC)]
  
  rule lookupVariableOccurrences0(({ node(X:Statements):Statements }) => (node({ X }):CompoundStatement))

  //context elaborateFunctionBody()

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

  // Memory
  //------------------------------------------------------
  syntax Operation ::= writeValue(ObjectID, Value) //[seqstrict(c)]

  context writeValue(HOLE, _) [result(ObjectIDC)]
  context writeValue(_:ObjectIDC, HOLE) [result(ValueC)]

  rule <k> writeValue(objectID(I), V:ValueC) => .K ...</k>
       <memory> M => M [ I <- V ] </memory>

  rule <k> readValue(objectID(I)) => M[I] ...</k>
       <memory> M </memory>
       requires I in_keys(M)

  // Names
  //-----------------------------------------------------
  rule <k> lookupObjectID(X) => ID ...</k>
       <returnVariables>... (X |-> ID:ObjectIDC) ...</returnVariables>


  // we need to have some context alias
  syntax KItem ::= neverMatches(K)
  context alias [c]: <k> neverMatches(HERE) ...</k> <phase> ExecutionPhase() </phase>

  //context alias [c]: <k> HERE:K ... </k> <phase> ExecutionPhase() </phase> [result(ExecResult)]

  syntax KItem ::= translationResultWrapper(TranslationResultCell) [symbol, klabel(translationResultWrapper)]
  // Start the execution phase
  rule <k> initialize(translationResultWrapper(X:TranslationResultCell)) => startExec() ~> programStartup() ...</k>
       <phase> ExecutionPhase() </phase>
       (<translation-result> _TR </translation-result> => X)

  syntax KItem ::= startExec()

  rule <k> startExec() => .K ...</k>
       <phase> _ => ExecutionPhase() </phase>
       <various-states> _ =>
         <execution-state>
           <stack> .List </stack>
           <local>
             <blocks> .List </blocks>
             <returnVariables> .Map </returnVariables> // Identifier |-> ObjectIDC
           </local>
           <global-variables> .Map </global-variables> // Identifier |-> ObjectIDC
           <memory> .Map </memory> // Int |-> Value (the key represents ObjectIDC)
           <objectid-counter> 0 </objectid-counter>
         </execution-state>
       </various-states>

  syntax Operation ::= programStartup()

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
       <k> (callFunction(F:Identifier) ~> Rest:K) => writeValue(objectID(I), voidValue()) ~> S </k>
       <global-function-declarations>... F |-> globalFunction(_, _T:FunctionType, functionBody(S:Statement)) ...</global-function-declarations>
       <stack>... (.List => ListItem(stackFrame(Rest, Blocks, RVs))) </stack>
       <blocks> Blocks:List => .List </blocks>
       <returnVariables> RVs => (unnamedReturnVariable() |-> objectID(I)) </returnVariables>
       <objectid-counter> I:Int => I +Int 1 </objectid-counter>

  rule [compound-nonempty]: <k> ({ Stmts:Statements }):CompoundStatement => enterBlock() ~> Stmts ~> leaveBlock() ...</k> 
  //rule [compound-empty]: <k> ({ }):CompoundStatement => enterBlock() ~> leaveBlock() ...</k> 

  syntax Operation ::= enterBlock() | leaveBlock()

  rule <k> enterBlock() => .K ...</k>
       <blocks>... (.List => ListItem(blockFrame())) </blocks>
       
  rule [leaveBlock-op]:
       <k> leaveBlock() => .K ...</k>
       <blocks>... (ListItem(blockFrame()) => .List) </blocks>
  
  //rule [leaveBlock-noop]:
  //     <k> leaveBlock() => .K ...</k>
  //     <blocks> .List </blocks>

  syntax Identifier ::= unnamedReturnVariable()

  rule [return-exp]:
    return E:Expression ; => returnValue(evaluateExpression(E))
  
  syntax ValueF ::= evaluateExpression(Expression) //[seqstrict(c)]
  
  context evaluateExpression(HOLE) [result(ExecResult)]
  
  rule evaluateExpression(V:Int) => intValue(V)
  //rule evaluateExpression(V:Bool) => boolValue(V)


  rule <k> Stmts:Statements => statementsToK(Stmts) ...</k>
       <phase> ExecutionPhase() </phase>
  
  syntax K ::= statementsToK(Statements) [function]  
  rule statementsToK(.Statements) => .K
  rule statementsToK((Stmt:Statement Stmts:Statements):Statements)
       => Stmt ~> statementsToK(Stmts)

  syntax Operation ::= returnValue(Value)

  context [ctx-return-value]: <k> returnValue(HOLE) ...</k>
          <phase> ExecutionPhase() </phase> [result(ValueC)]

  rule [return-value]:
    <k> returnValue(V:ValueC)
      => writeValue(lookupObjectID(unnamedReturnVariable()), V)
      ~> return ;
    ...</k>
    <phase> ExecutionPhase() </phase>

  rule [return-from-block]:
       <k> (.K => leaveBlock()) ~> return ; ...</k>
       <blocks>... ListItem(_) </blocks>

  // a return statement discards everything that was to be done later (_Rest),
  // and instead of it retrieves a continuation from the stack
  rule [return-no-block]:
       <k> return ; ~> _Rest => readValue(objectID(I)) ~> Cont </k>
       <blocks> .List  => Blocks</blocks>
       <stack>... (ListItem(stackFrame(Cont, Blocks, RVs)) => .List) </stack>
       <returnVariables> (unnamedReturnVariable() |-> objectID(I:Int)) => RVs </returnVariables>

  // A conditional / branching operation
  syntax Operation ::= ite(BoolValue, Operation, Operation) [strict(1)]

  rule [ite-true]: ite(boolValue(true), X, _Y) => X
  rule [ite-false]: ite(boolValue(false), _X, Y) => Y

  // Are those two value categories enough for the simplified language?
  // Also, we query on value categories in translation time
  syntax ValueCategoryC ::= lvalue() | rvalue()
  syntax ValueCategoryF ::= valueCategoryOf(Expression) //[seqstrict(c)]
  syntax ValueCategory ::= ValueCategoryC | ValueCategoryF
  syntax TranslateResult ::= ValueCategoryC

  //context valueCategoryOf()

  // I think this is not true, because it depends on whether the identifier is an in/out parameter
  // See https://github.com/hsutter/708/blob/main/708.pdf
  rule valueCategoryOf(_X:Identifier) => lvalue()
  rule valueCategoryOf(_) => rvalue()


  // lemmas
  //rule {X:Int #Equals (X:Int +Int 1) } => #Bottom [simplification]
endmodule
