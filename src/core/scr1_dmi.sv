/// Copyright by Syntacore LLC © 2016-2021. See LICENSE for details
/// @file       <scr1_dmi.sv>
/// @brief      Debug Module Interface (DMI)
///

//------------------------------------------------------------------------------
 //
 // Functionality:
 // - Provides TAPC with access to Debug Module (DM) and DTMCS
 //
 // Structure:
 // - DMI <-> TAP interface
 // - DMI <-> DM interface
 //
//------------------------------------------------------------------------------

`include "scr1_arch_description.svh"

`ifdef SCR1_DBG_EN
`include "scr1_dm.svh"

module scr1_dmi (
    // System
    input  logic                                    rst_n,                      // DMI unit reset
    input  logic                                    clk,                        // DMI unit clock

    // TAP interface
    input  logic                                    tapcsync2dmi_ch_sel_i,      // Debug Transport Module Chain Select
    input  logic [SCR1_DBG_DMI_CH_ID_WIDTH-1:0]     tapcsync2dmi_ch_id_i,       // Debug Transport Module Chain ID
    input  logic                                    tapcsync2dmi_ch_capture_i,  // Debug Transport Module Chain Capture
    input  logic                                    tapcsync2dmi_ch_shift_i,    // Debug Transport Module Chain Shift
    input  logic                                    tapcsync2dmi_ch_update_i,   // Debug Transport Module Chain Update
    input  logic                                    tapcsync2dmi_ch_tdi_i,      // Debug Transport Module Chain TDI
    output logic                                    dmi2tapcsync_ch_tdo_o,      // Debug Transport Module Chain TDO

    // DM interface
    input logic                                     dm2dmi_resp_i,              // DMI response
    input logic [SCR1_DBG_DMI_DATA_WIDTH-1:0]       dm2dmi_rdata_i,             // DMI read data
    output logic                                    dmi2dm_req_o,               // DMI request
    output logic                                    dmi2dm_wr_o,                // DMI write
    output logic [SCR1_DBG_DMI_ADDR_WIDTH-1:0]      dmi2dm_addr_o,              // DMI address
    output logic [SCR1_DBG_DMI_DATA_WIDTH-1:0]      dmi2dm_wdata_o              // DMI write data
);

//------------------------------------------------------------------------------
// Local parameters declaration
//------------------------------------------------------------------------------

// Debug Transport Module Status parameters
//------------------------------------------------------------------------------

// DTMS
localparam int                                         DTMCS_RESERVEDB_HI = 31;
localparam int                                         DTMCS_RESERVEDB_LO = 18;
localparam int                                         DTMCS_DMIHARDRESET = 17;
localparam int                                         DTMCS_DMIRESET     = 16;
localparam int                                         DTMCS_RESERVEDA    = 15;
localparam int                                         DTMCS_IDLE_HI      = 14;
localparam int                                         DTMCS_IDLE_LO      = 12;
localparam int                                         DTMCS_DMISTAT_HI   = 11;
localparam int                                         DTMCS_DMISTAT_LO   = 10;
localparam int                                         DTMCS_ABITS_HI     = 9;
localparam int                                         DTMCS_ABITS_LO     = 4;
localparam int                                         DTMCS_VERSION_HI   = 3;
localparam int                                         DTMCS_VERSION_LO   = 0;
logic                                               dtmcs_dmihardreset_cmb;
logic                                               dtmcs_dmireset_cmb;

// Debug Module Interface parameters
//------------------------------------------------------------------------------

localparam int                                         DMI_OP_LO   = 0;
localparam int                                         DMI_OP_HI   = DMI_OP_LO + SCR1_DBG_DMI_OP_WIDTH - 1;
localparam int                                         DMI_DATA_LO = DMI_OP_HI + 1;
localparam int                                         DMI_DATA_HI = DMI_DATA_LO + SCR1_DBG_DMI_DATA_WIDTH - 1;
localparam int                                         DMI_ADDR_LO = DMI_DATA_HI + 1;
localparam int                                         DMI_ADDR_HI = DMI_ADDR_LO + SCR1_DBG_DMI_ADDR_WIDTH - 1;

//------------------------------------------------------------------------------
// Local signals declaration
//------------------------------------------------------------------------------

// TAP data register
logic                                               tap_dr_upd;
logic [SCR1_DBG_DMI_DR_DMI_ACCESS_WIDTH-1:0]        tap_dr_ff;
logic [SCR1_DBG_DMI_DR_DMI_ACCESS_WIDTH-1:0]        tap_dr_shift;
logic [SCR1_DBG_DMI_DR_DMI_ACCESS_WIDTH-1:0]        tap_dr_rdata;
logic [SCR1_DBG_DMI_DR_DMI_ACCESS_WIDTH-1:0]        tap_dr_next;

// DM read data register
logic                                               dm_rdata_upd;
logic [SCR1_DBG_DMI_DATA_WIDTH-1:0]                 dm_rdata_ff;

logic                                               tapc_dmi_access_req;
logic                                               tapc_dtmcs_sel;

//------------------------------------------------------------------------------
// DMI <-> TAP interface
//------------------------------------------------------------------------------

// TAPC read data multiplexer
//------------------------------------------------------------------------------

assign tapc_dtmcs_sel = (tapcsync2dmi_ch_id_i == 1'd1);

// DMI operation is always successful in the current implementation
always_comb begin
    tap_dr_rdata = '0;

    if(tapc_dtmcs_sel) begin
        tap_dr_rdata[DTMCS_RESERVEDB_HI:DTMCS_RESERVEDB_LO] = 'b0;
        tap_dr_rdata[DTMCS_DMIHARDRESET]                    = 'b0;
        tap_dr_rdata[DTMCS_DMIRESET]                        = 'b0;
        tap_dr_rdata[DTMCS_RESERVEDA]                       = 'b0;
        tap_dr_rdata[DTMCS_IDLE_HI:DTMCS_IDLE_LO]           = 'b0;
        tap_dr_rdata[DTMCS_DMISTAT_HI:DTMCS_DMISTAT_LO]     = 'b0;
        tap_dr_rdata[DTMCS_ABITS_HI  :DTMCS_ABITS_LO]       = (DTMCS_ABITS_HI-DTMCS_ABITS_LO+1)'(SCR1_DBG_DMI_ADDR_WIDTH);
        tap_dr_rdata[DTMCS_VERSION_LO]                      = 1'b1;
    end else begin
        tap_dr_rdata[DMI_ADDR_HI:DMI_ADDR_LO]               = 'b0;
        tap_dr_rdata[DMI_DATA_HI:DMI_DATA_LO]               = dm_rdata_ff;
        tap_dr_rdata[DMI_OP_HI  :DMI_OP_LO]                 = 'b0;
    end
end

assign tap_dr_shift = tapc_dtmcs_sel
                    ? {9'b0, tapcsync2dmi_ch_tdi_i, tap_dr_ff[SCR1_DBG_DMI_DR_DTMCS_WIDTH-1:1]}
                    : {tapcsync2dmi_ch_tdi_i, tap_dr_ff[SCR1_DBG_DMI_DR_DMI_ACCESS_WIDTH-1:1]};

// TAP data register
//------------------------------------------------------------------------------

assign tap_dr_upd = tapcsync2dmi_ch_capture_i | tapcsync2dmi_ch_shift_i;

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        tap_dr_ff <= '0;
    end else if(tap_dr_upd) begin
        tap_dr_ff <= tap_dr_next;
    end
end

assign tap_dr_next = tapcsync2dmi_ch_capture_i ? tap_dr_rdata
                   : tapcsync2dmi_ch_shift_i   ? tap_dr_shift
                                               : tap_dr_ff;

assign dmi2tapcsync_ch_tdo_o = tap_dr_ff[0];

//------------------------------------------------------------------------------
// DMI <-> DM interface
//------------------------------------------------------------------------------

assign tapc_dmi_access_req = tapcsync2dmi_ch_update_i & tapcsync2dmi_ch_sel_i
                           & (tapcsync2dmi_ch_id_i == 2'd2);

always_comb begin
    dmi2dm_req_o           = 1'b0;
    dmi2dm_wr_o            = 1'b0;
    dmi2dm_addr_o          = 1'b0;
    dmi2dm_wdata_o         = 1'b0;

    if(tapc_dmi_access_req) begin
        dmi2dm_req_o   = tap_dr_ff[DMI_OP_HI  :DMI_OP_LO] != 2'b00;
        dmi2dm_wr_o    = tap_dr_ff[DMI_OP_HI  :DMI_OP_LO] == 2'b10;
        dmi2dm_addr_o  = tap_dr_ff[DMI_ADDR_HI:DMI_ADDR_LO];
        dmi2dm_wdata_o = tap_dr_ff[DMI_DATA_HI:DMI_DATA_LO];
    end
end

// DM read data register
//------------------------------------------------------------------------------

assign dm_rdata_upd = dmi2dm_req_o & dm2dmi_resp_i & ~dmi2dm_wr_o;

always_ff @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        dm_rdata_ff <= '0;
    end else if (dm_rdata_upd) begin
        dm_rdata_ff <= dm2dmi_rdata_i;
    end
end

endmodule : scr1_dmi

`endif // SCR1_DBG_EN
