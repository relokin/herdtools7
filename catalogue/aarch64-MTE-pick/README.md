aarch64-MTE: Catalogue for AArch64 with MTE and instructions with pick dependencies
===================================================================================

Tests that exercise the ordering rules of the MTE semantics of the
memory model and pick dependencies.

Simulating with herd7
---------------------

    % herd7 -variant mte,sync tests/@all

Running with litmus7
--------------------

litmus7 does not currently support the tests in this catalogue.
