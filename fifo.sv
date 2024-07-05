module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input  logic             clk_i,
    input  logic             rst_i,
    input  logic             pop_i,
    input  logic             push_i,
    input  logic [WIDTH-1:0] data_i,
    output logic             empty_o,
    output logic             full_o,
    output logic [WIDTH-1:0] data_o
);

    parameter PTR_W = $clog2(DEPTH);

    logic [WIDTH-1:0] data [DEPTH];

    logic [PTR_W:0] wr_ptr;
    logic [PTR_W:0] rd_ptr;

    assign empty_o = wr_ptr == rd_ptr;
    assign full_o  = (wr_ptr[PTR_W] != rd_ptr[PTR_W]) &&
                     (wr_ptr[PTR_W-1:0] == rd_ptr[PTR_W-1:0]);

    always_ff @(posedge clk_i)
        if (rst_i)
            rd_ptr <= '0;
        else if (pop_i)
            rd_ptr <= rd_ptr + 1'b1;

    always_ff @(posedge clk_i)
        if (rst_i)
            wr_ptr <= '0;
        else if (push_i)
            wr_ptr <= wr_ptr + 1'b1;

    always_ff @(posedge clk_i)
        if (push_i)
            data[wr_ptr[PTR_W-1:0]] <= data_i;

    assign data_o = data[rd_ptr[PTR_W-1:0]];

endmodule
