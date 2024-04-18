aarch64-VMSA: Catalogue with the semantics of Armv8-A VMSA
============================================================

Includes tests that exercise the semantics of the Virtual Memory
System Architecture. Most of the tests in this catalogue concurrently
update and use Translation Table Descriptors.

The tests in this catalogue:
- Can address the Stage 1, Level-3 Translation Table Descriptor (TTD)
of a locations `x` as `PTE(x)`.
- Assign a tuple of the following format as the value of `PTE(x)`
`(oa:PA(x), valid:<OA>, af:{0,1}, db:{0,1}, dmb:{0,1}, el0:{0,1})` where:
    - `oa`: The Output Address encoded of the TTD,
    - `valid`: The Valid bit of the TTD,
    - `af`: The AF bit of the TTD (Lower attributes),
    - `db`: The complement of the nDirty bit of the TTD (Lower attributes),
    - `dbm`: The DBM of the TTD (Upper attributes), and
    - `el0`: The AP[1] bit of the TTD (Lower attributes).
- Use `TLBI` instructions to invalidate one or more entries in the
  TLB. For example, if `X9` is initialized with address of `x`, a test
  will use a sequence of instructions such as the following to
  invalidate the TLB for a location `x`

>          LSR X9,X9,#12
>          TLBI VAAE1IS,X9

- In their post-condition, can include predicates that are validated
if the execution has encountered an MMU Fault. As a result, the a
predicate of the following format might appear in the post-condition of a test:
`fault(P<n>[:<label>][:<location>][:<fault type>])` where:
    - `P<n>` is the thread that encountered a fault, for example `P0`,
    - `<label>` is the label of the instruction that raised the fault,
      for example `L0`,
    - `<location>` is the location that was associated with the fault,
      for example `x`, and
    - `<fault type>` is the type of fault, for example `MMU:Translation`.

- Might specify handlers for faults that happen in a given thread. The
  fault handlers are encoded as a separate thread with the label
  `P<n>.F`. For example a thread with the label `P1.F` specifies the
  handler that will be executed if there is a fault in the execution
  of `P1`.

Simulating with herd7
---------------------

    % herd7 -variant vmsa,fatal -kinds tests/VMSA-kinds.txt tests/@all

Running with litmus7
--------------------

VMSA litmus tests need to control the Translation Table Descriptors as
well as exceptions and exception handlers. Consecuently, litmus7 needs
to generate binaries that run in EL1 using hardware
virtualization. `-mach kvm-aarch64` instructs litmus7 to generate such
tests. In this mode, litmus7 generates source code that dependends on
[kvm-unit-tests](http://www.linux-kvm.org/page/KVM-unit-tests). Assuming
that the user has downloaded a copy of kvm-unit-test and [build its
source]{https://gitlab.com/kvm-unit-tests/kvm-unit-tests/-/blob/master/README.md?ref_type=heads#building-the-tests)
in the folder ${KUT_DIR}:

    % mkdir ${KUT_DIR}/litmus
    % litmus7 -mach kvm-aarch64 -a 2 -o ${KUT_DIR}/litmus -kinds tests/VMSA-kinds.txt tests/@armv8-a
    % cd ${KUT_DIR}/litmus
    % make
    % cd ..
    % sh ./litmus/run.sh

Some tests in this catalogue require support for FEAT_LSE. If hardware
implements Armv8.1-A which includes FEAT_LSE, you can instead run
litmus7 with following command:

    % litmus7 -mach kvm-armv8.1 -a 2 -o ${KUT_DIR}/litmus -kinds tests/VMSA-kinds.txt tests/@all

> **_NOTE:_** litmus7 and the C compiler might emit warnings for the tests:
> - LDR,
> - LDRaf0-HA,
> - LDRaf0-noHA,
> - LDRv1,
> - MP+DSB+ctrl,
> - NT-00-data,
> - NT-01-data,
> - NT-02-data,
> - NT-03-data,
> - NT-04-data,
> - NT-20-data+dsb,
> - NT-20-data,
> - NT-23-data+dsb,
> - NT-23-data,
> - NT-30-data+dsb,
> - NT-30-data,
> - NT-33-data+dsb,
> - NT-33-data,
> - R3+W,
> - R3+W,
> - R3+W,
> - R3-DSBs+W,
> - R3-DSBs+W,
> - R3-DSBs+W,
> - STR-db0-noHD,
> - STR,
> - STRx+STCLRptex+af,
> - STRx+STCLRptex+db+dbm,
> - STRx+STCLRptex+db,
> - STRx+STCLRptex+db2+dbm,
> - STRx+STCLRptex+db2,
> - STRx+STCLRptex+db3+dbm,
> - STRx+STCLRptex+db3,
> - STRx+STCLRptex+db4,
> - coRWImpExp+WExp, and
> - coRWImpExp.
> These are known and do not affect the correctness of these tests.
