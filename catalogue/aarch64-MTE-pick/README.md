aarch64-MTE: Catalogue for AArch64 with MTE and instructions with pick dependencies
===================================================================================

Tests that exercise the conjuction of MTE and pick dependencies
ordering semantics of the AArch64 architecture.

Simulating with herd7
---------------------

    % herd7 -variant mte,sync tests/@all

Running with litmus7
--------------------

litmus7 does not currently support the tests in this catalogue.
