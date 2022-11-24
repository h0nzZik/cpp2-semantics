module SIMPLE-TEST-PROVE-CPP2-SPEC
imports CPP2
  imports ML-SYNTAX

  rule M:Map [ K:Int <- _V1:ValueC ] [ K:Int <- V2:ValueC ] => M [ K <- V2 ] [simplification]

  rule (#Exists _X:Int . #Top:Int) => #Top:Int [simplification]
  rule (#Exists Rest . #Exists V . { _M:Map [ Key:Int <- intValue ( _I:Int ) ] #Equals (Key:Int |-> V) Rest })
     => #Top [simplification]

claim [name]: 
     <k>  callFunction(String2Id("foo")) ~> readValue(lookupObjectID(unnamedReturnVariable())) => intValue(?_I:Int) </k>
     <execution-state> _ => ?_ </execution-state>
     
<translation-result>
  <global-function-declarations>
    String2Id ( "foo" ) |-> globalFunction ( String2Id ( "foo" ) , ( .ParameterDeclarations ) -> String2Id ( "int" ) .Contracts , functionBody ( { return 3 ;  .Statements } ) ) String2Id ( "bar" ) |-> globalFunction ( String2Id ( "bar" ) , ( .ParameterDeclarations ) -> String2Id ( "int" ) .Contracts , functionBody ( { return 3 ;  .Statements } ) )
  </global-function-declarations>
  <global-variable-declarations>
    .Map
  </global-variable-declarations>
</translation-result>
<phase>ExecutionPhase()</phase>

endmodule
