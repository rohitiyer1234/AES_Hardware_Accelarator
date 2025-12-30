axi/ — AXI4-Lite Interface & Register Subsystem

Directory README

1. Purpose of the AXI Subsystem

The axi/ directory contains all logic required to expose the AES accelerator as a memory-mapped AXI4-Lite peripheral.

This subsystem is responsible for:

Translating AXI4-Lite bus transactions into single-cycle internal register accesses

Providing a stable firmware-visible programming model

Isolating AXI protocol complexity from cryptographic logic

Acting as the only boundary between software and hardware

No AES datapath, key expansion, or mode logic should ever directly interact with AXI signals.

This separation is intentional and critical for correctness, reuse, and verification.

2. Architectural Role in the Full System

At the system level:

Firmware / CPU
    |
    | AXI4-Lite
    |
[ axi_slave ]
    |
[ axi_regs ]
    |
[ axi_control ]
    |
[ AES Core + Modes + Key Expansion ]


The AXI subsystem is split into three layers, each with a clearly defined responsibility:

Layer	Module	Responsibility
Protocol	axi_slave.v	AXI4-Lite handshake & timing
Register file	axi_regs.v	Address decoding & storage
Control	axi_control.v	Operation sequencing & status

This layered approach prevents:

Protocol logic leaking into datapath logic

Firmware-visible behavior changing when AES internals change

3. AXI4-Lite Design Assumptions

This project assumes a minimal, compliant AXI4-Lite master, typically a CPU or DMA engine.

Supported AXI Features

Single-beat read/write

32-bit data bus

In-order transactions

One outstanding transaction per channel

Explicitly NOT Supported

Bursts

Out-of-order responses

Exclusive accesses

Narrow transfers (<32 bits)

These exclusions are intentional and aligned with AXI4-Lite usage in control/status peripherals.

4. Module Breakdown
4.1 axi_slave.v — AXI Protocol Adapter
Purpose

axi_slave.v implements the AXI4-Lite handshake logic and converts bus transactions into simple internal strobes.

It does not:

Decode addresses

Store registers

Know anything about AES

It only answers the question:

“Has software performed a read or write, and if so, what address and data?”

External Interface (AXI-facing)

Key AXI signals handled:

Write Address Channel: AW*

Write Data Channel: W*

Write Response Channel: B*

Read Address Channel: AR*

Read Data Channel: R*

All handshakes strictly follow AXI4-Lite rules:

VALID driven by master

READY driven by slave

Transfer occurs when both are high

Internal Interface (Register-facing)

The AXI protocol is reduced to two clean strobes:

Write side
wr_en    // 1-cycle pulse
wr_addr  // full byte address
wr_data  // 32-bit write data
wr_strb  // byte enables

Read side
rd_en    // 1-cycle pulse
rd_addr  // full byte address
rd_data  // return data from register block


This abstraction allows the rest of the design to behave as if it were driven by a simple microcontroller-style bus.

Design Choices

Write address and write data are latched independently

AXI allows them to arrive in any order

wr_en is asserted only when both AW and W have been seen

Read is a single-cycle request–response model

No combinational paths from AXI inputs to outputs (timing-safe)

4.2 axi_regs.v — Memory-Mapped Register File
Purpose

axi_regs.v implements the software-visible register map.

It is the only module that knows:

Which addresses exist

Which registers are writable

Which registers are read-only

Which registers are driven by hardware

This module defines the firmware contract.

Address Map (Byte Offsets)
Offset	Register	Direction	Description
0x00	CTRL_REG1	W/R	Start, enc/dec, future control
0x04	CTRL_REG2	W/R	Reserved / future
0x08	STATUS	R	Busy / Done
0x0C	MODE	W/R	AES mode select
0x10–0x1C	BASE_KEY[0..3]	W	Initial AES key
0x20–0x2C	DATA_IN[0..3]	W	Plaintext / Ciphertext input
0x30–0x3C	IV[0..3]	W	Initialization Vector
0x2C–0x38	DATA_OUT[0..3]	R	Result output

All registers are 32-bit word-aligned.

Write Behavior

Registers update only on wr_en

Address decoding uses wr_addr[7:0]

Writes to read-only registers are ignored

No side effects occur inside this module

This ensures:

Writes are deterministic

Control sequencing is handled elsewhere

Read Behavior

rd_data is driven combinationally

Read-only registers reflect live hardware state

No registers are modified on read

Design Constraints

No AES logic here

No FSMs here

No timing dependencies here

This module must remain purely structural.

4.3 axi_control.v — Firmware–Hardware Bridge
Purpose

axi_control.v converts static register contents into time-ordered hardware actions.

This is the brain of the peripheral.

It answers:

When does AES start?

When is the block busy?

When is the result valid?

When can firmware read outputs?

Inputs

From axi_regs:

ctrl_reg1 — start, enc/dec

mode_reg — AES mode

data_in_mem — input data

IV_W — IV words

From AES core:

aes_done

aes_result

Outputs

To AES subsystem:

aes_start (single-cycle pulse)

plaintext_lat

mode_lat

iv_lat

enc_dec_lat

To firmware:

status_reg

data_out_mem

Control FSM

The FSM has three states:

State	Meaning
IDLE	Waiting for START
RUN	AES operation in progress
DONE	Result available

Key properties:

aes_start pulses once per START

START must be cleared and reasserted by firmware

No re-entrancy allowed

Status bits are firmware-stable

Why Control Is Separate from Registers

This separation ensures:

Firmware can write registers in any order

Hardware acts only when explicitly commanded

AES latency does not affect AXI timing

Multi-cycle operations remain deterministic

5. Reset Strategy in AXI Subsystem

All AXI-facing modules use:

resetn  // active-low reset


Reasons:

AXI specification convention

SoC reset-tree compatibility

Safe default behavior

The AES datapath reset is derived separately and does not affect AXI registers unless explicitly designed to.

6. Firmware Programming Model (AXI Perspective)

Typical firmware flow:

Write key

Write IV (if required)

Write input data

Write MODE

Write CTRL_REG1.START

Poll STATUS.DONE

Read DATA_OUT

The AXI subsystem guarantees:

Writes are captured atomically

START is edge-detected

STATUS is stable and race-free

7. Why This AXI Design Is Future-Proof

This AXI layer will not change when:

AES internals are replaced

Key expansion logic is added

Decrypt datapaths are implemented

Modes are extended

Only axi_control may gain additional outputs, never behavioral changes.

8. Summary

The axi/ directory provides:

A clean AXI4-Lite slave

A stable register map

A deterministic control FSM

A strict firmware–hardware contract

It intentionally contains no cryptography, only control.

This is the correct and scalable way to build a hardware accelerator.
