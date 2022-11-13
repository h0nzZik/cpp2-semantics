module SPEC
    imports CPP2

    claim [true-reaches-true]: <k> true => true </k>

    claim [ite-true-works]: <k> ite(boolValue(true), 3, 4) => 3 </k>
    claim [ite-false-works]: <k> ite(boolValue(false), 3, 4) => 4 </k>
endmodule