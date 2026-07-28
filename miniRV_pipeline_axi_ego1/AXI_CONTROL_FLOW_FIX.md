# AXI board control-flow fix

## Observed evidence

After the diagnostic program received `A`, ILA showed:

- UART `rx_valid` asserted with `rx_data = 0x41`, then cleared after the CPU read;
- `pc` remained at `0x00000164`;
- instruction reads repeated among unrelated function addresses such as
  `0x00000084`, `0x000000FC`, and `0x00000164`;
- no subsequent UART MMIO write or LED/display update occurred.

The `ex_bj_target_in_id` duplicate-flush optimization assumes the target
instruction already in ID remains a valid sequential fetch. That assumption is
safe for the zero-latency Trace memory but not for delayed AXI responses, which
may be discarded and reissued after redirects.

## Fix

`RUN_TRACE` retains the original target-in-ID suppression. The physical-board
AXI build now redirects and flushes every taken branch, JAL, and JALR:

```verilog
`ifdef RUN_TRACE
assign ex_bj_f = ex_bj_taken && !ex_bj_target_in_id;
`else
assign ex_bj_f = ex_bj_taken;
`endif
```

This trades a small amount of board-mode control-flow performance for correct,
deterministic AXI instruction sequencing.

## Board validation

Build with:

```tcl
source rebuild_ego1_ila.tcl
```

After programming the matching bit/ltx pair, press and release S6. The staged
diagnostic should reach `600D600D`/LED `00A5`, print its PASS message, and an
input `A` should echo and change the visible value to `00000041`.
