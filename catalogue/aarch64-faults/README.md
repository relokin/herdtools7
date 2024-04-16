aarch64-faults: Catalogue that demonstrates supported Faults
============================================================

The tests in this catalogue execute instructions that generate
different type of faults.

Simulating with herd7
---------------------

    % herd7 -kinds tests/kinds.txt tests/@all

Running with litmus7
--------------------

The litmus tests in this catalogue need to control the Translation
Table Descriptors as well as exceptions and exception
handlers. Consecuently, litmus7 needs to generate binaries that run in
EL1 using hardware virtualization. `-mach kvm-aarch64` instructs
litmus7 to generate such tests. In this mode, litmus7 generates source
code that dependends on
[kvm-unit-tests](http://www.linux-kvm.org/page/KVM-unit-tests). Assuming
that the user has downloaded a copy of kvm-unit-test and [build its
source]{https://gitlab.com/kvm-unit-tests/kvm-unit-tests/-/blob/master/README.md?ref_type=heads#building-the-tests)
in the folder ${KUT_DIR}:

    % mkdir ${KUT_DIR}/litmus
    % litmus7 -mach kvm-aarch64 -a 2 -kinds tests/kinds.txt -o ${KUT_DIR}/litmus tests/{3faults,LDRaf0F,STRdb0F,UDF,noUDF}.litmus
    % cd ${KUT_DIR}/litmus
    % make
    % cd ..
    % sh ./litmus/run.sh

> Note: litmus7 does not support MTE and, consencuently, cannot run the test LDRredF.
