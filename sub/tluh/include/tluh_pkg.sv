// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Modified by MERL, for Azadi SoC




package tluh_pkg;

  parameter ArbiterImpl = "PPC"; // the arbiter is the one that decides which master gets to use the bus

  function automatic integer vbits(integer value); // this function returns the number of bits required to represent a value
    return (value == 1) ? 1 : $clog2(value);
  endfunction

  localparam int TL_AW  = 32; // AW stands for Address Width
  localparam int TL_DW  = 32; // DW stands for Data Width (it is 32 bits not bytes)
  localparam int TL_AIW = 8; // AIW stands for Address Index Width
  localparam int TL_DIW = 1; // DIW stands for Data Index Width
  localparam int TL_DBW = (TL_DW>>3); // DBW stands for Data Byte Width  // 4 bytes
  localparam int TL_SZW = $clog2($clog2(TL_DBW)+1); // SZW stands for Size Width //2
  localparam int TL_BEATSMAX = (2**(2**TL_SZW - 1)) / TL_DBW;
  localparam int TL_BEATSMAXW = $bits(TL_BEATSMAX);

  // opcodes for channel A messages/operations defined in official TileLink spec
  typedef enum logic [2:0] {
    PutFullData     = 3'h0,
    PutPartialData  = 3'h1,
    Get             = 3'h4, 
    // additional opcodes for TL-UH interface
    ArithmeticData  = 3'h2,
    LogicalData     = 3'h3,
    Intent          = 3'h5

  } tluh_a_m_op; // a_m_op stands for address master operation
  
  // opcodes for channel D messages/operations defined in official TileLink spec
  typedef enum logic [2:0] {
    AccessAck     = 3'h0,
    AccessAckData = 3'h1,
    // additional opcodes for TL-UH interface
    HintAck       = 3'h2
  } tluh_d_m_op;  // d_m_op stands for data master operation

  // make enum for the a_param field 
  // we will need 2 enums one for arithmetic and one for logical
  // let's begin by the enum of arithmetic operations --> MIN – MAX – MINU – MAXU – ADD
  typedef enum logic [2:0] {
    MIN  = 3'h0,
    MAX  = 3'h1,
    MINU = 3'h2,
    MAXU = 3'h3,
    ADD  = 3'h4
  } tluh_a_param_arith;

  // now let's make the enum for logical operations --> XOR – OR – AND – SWAP
  typedef enum logic [2:0] {
    XOR  = 3'h0,
    OR   = 3'h1,
    AND  = 3'h2,
    SWAP = 3'h3
  } tluh_a_param_log;

  // make enum for the a_param in case of intent --> PrefetchRead - PrefetchWrite
  typedef enum logic [2:0] {
    PrefetchRead  = 3'h0,
    PrefetchWrite = 3'h1
  } tluh_a_param_intent;

  typedef struct packed {
    logic                   a_valid;
    tluh_a_m_op             a_opcode;
    logic      [2:0]        a_param;
    logic      [TL_SZW-1:0] a_size;  // in terms of log2(bytes). the size of the response message (is 2^a_size bytes) - max to be of value 3 indicating that tha accessed data is of (2^3 = 8) bytes and the channel width is only 32 bits (4 bytes) (in case of burst the number of beats will be 8 / 4 = 2 beats)
    logic      [TL_AIW-1:0] a_source;
    logic      [TL_AW-1:0]  a_address;
    logic      [TL_DBW-1:0] a_mask;
    logic      [TL_DW-1:0]  a_data; // 32 bits (4 bytes)
    logic                   d_ready;
  } tluh_h2d_t; // h2d stands for Host to Device

  localparam tluh_h2d_t TL_H2D_DEFAULT = '{
    d_ready:  1'b1,
    a_opcode: tluh_a_m_op'('0),
    default:  '0
  };

  typedef struct packed {
    logic                   d_valid;
    tluh_d_m_op             d_opcode;
    logic             [2:0] d_param;
    logic      [TL_SZW-1:0] d_size;
    logic      [TL_AIW-1:0] d_source;
    logic      [TL_DIW-1:0] d_sink;
    logic      [TL_DW-1:0]  d_data;
    logic                   d_error;
    logic                   a_ready;
  } tluh_d2h_t; // d2h stands for Device to Host

  localparam tluh_d2h_t TL_D2H_DEFAULT = '{
    a_ready:  1'b1,
    d_opcode: tluh_d_m_op'('0),
    default:  '0
  };

endpackage
