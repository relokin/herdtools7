aarch64-MTE: Catalogue for AArch64 with MTE
===========================================

Tests that exercise the basic ordering rules of the MTE semantics of the memory model.

Simulating with herd7
---------------------

    % herd7 -variant mte,sync -kinds tests/kinds.txt tests/@all

Running with litmus7
--------------------

litmus7 does not currently support the tests in this catalogue.
