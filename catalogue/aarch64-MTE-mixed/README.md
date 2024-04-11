aarch64-MTE-mixed: Catalogue for AArch64 with MTE and mixed size semantics
==========================================================================

Tests that exercise the basic ordering rules of the MTE and mixed size
semantics of the memory model.

Simulating with herd7
---------------------

    % herd7 -variant mte,sync,mixed tests/@all

Running with litmus7
--------------------

litmus7 does not currently support the tests in this catalogue.
