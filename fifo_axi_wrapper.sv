module fifo_axi_wrapper #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input  logic             clk_i,
    input  logic             rst_i,
    input  logic             up_valid,
    input  logic [WIDTH-1:0] up_data,
    input  logic             down_ready,
    output logic             up_ready,
    output logic             down_valid,
    output logic [WIDTH-1:0] down_data
);
    logic push;
    logic pop;
    logic empty;
    logic full;

    assign push = up_ready && up_valid;
    assign pop  = down_ready && down_valid;

    assign up_ready   = ~ full;
    assign down_valid = ~ empty;

    fifo #(
        .WIDTH (WIDTH),
        .DEPTH (DEPTH)
    ) i_fifo (
        .clk_i   ( clk_i     ),
        .rst_i   ( rst_i     ),
        .pop_i   ( pop       ),
        .push_i  ( push      ),
        .data_i  ( up_data   ),
        .empty_o ( empty     ),
        .full_o  ( full      ),
        .data_o  ( down_data )
    );

endmodule
