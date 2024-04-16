aarch64-MTE-mixed: Catalogue for AArch64 with MTE and mixed size semantics
==========================================================================

Tests that exercise the conjuction of MTE and mixed-size ordering
semantics of the AArch64 architecture.

Simulating with herd7
---------------------

    % herd7 -variant mte,sync,mixed tests/@all

Running with litmus7
--------------------

litmus7 does not currently support the tests in this catalogue.
