aarch64: Catalogue with base tests for AArch64
==============================================

Includes tests that exercise the semantics of coherence (for example,
coRR), message passing (for example, MP) and store buffering (for
example, SB) and load buffering (for example, LB).

Simulating with herd7
---------------------

    % herd7 -kinds tests/kinds.txt tests/@all

Running with litmus7
--------------------

    # Assuming there exists a folder at the path ${TESTS_DIR}
    % litmus7 -a 2 -kinds tests/kinds.txt -o ${TESTS_DIR} tests/@all
    % cd ${TESTS_DIR}
    % make
    % sh ./run.sh
