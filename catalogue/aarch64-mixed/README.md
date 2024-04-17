aarch64-mixed: Catalogue for AArch64 with mixed size semantics
==============================================================

Tests with memory instructions that generate accesses with overalping
Memory effects (for example, in CO-MIXED-20cc+H; P0 executes a STR
byte to x and LDR half-word from x, and P1 executes a STR half-word to
x)

Simulating with herd7
---------------------

    % herd7 -variant mixed -kinds tests/kinds.txt tests/@all

Running with litmus7
--------------------

    # Assuming there exists a folder at the path ${TESTS_DIR}
    % litmus7 -a 2 -kinds tests/kinds.txt -o ${TESTS_DIR}/ tests/@all
    % cd ${TESTS_DIR}
    % make
    % sh ./run.sh
