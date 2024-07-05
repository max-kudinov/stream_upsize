module stream_upsize #(
    parameter T_DATA_WIDTH = 4,
    parameter T_DATA_RATIO = 2
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [T_DATA_WIDTH-1:0] s_data_i,
    input  logic                    s_last_i,
    input  logic                    s_valid_i,
    output logic                    s_ready_o,
    output logic [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0],
    output logic [T_DATA_RATIO-1:0] m_keep_o,
    output logic                    m_last_o,
    output logic                    m_valid_o,
    input  logic                    m_ready_i
);

    parameter PTR_W      = $clog2(T_DATA_RATIO);
    parameter FIFO_W     = T_DATA_WIDTH * T_DATA_RATIO + T_DATA_RATIO + 1;
    parameter FIFO_DEPTH = 8;

    logic [T_DATA_RATIO-1:0][T_DATA_WIDTH-1:0] data;
    logic        [PTR_W-1:0]                   wr_ptr;
    logic [T_DATA_RATIO-1:0]                   keep;

    logic [FIFO_W-1:0] fifo_data_in;
    logic [FIFO_W-1:0] fifo_data_out;

    logic write;
    logic full;
    logic send;

    fifo_axi_wrapper #(
        .WIDTH (FIFO_W),
        .DEPTH (FIFO_DEPTH)
    ) i_fifo (
        .clk_i      ( clk           ),
        .rst_i      ( ~ rst_n       ),
        .up_valid   ( send          ),
        .up_data    ( fifo_data_in  ),
        .down_ready ( m_ready_i     ),
        .up_ready   ( s_ready_o     ),
        .down_valid ( m_valid_o     ),
        .down_data  ( fifo_data_out )
    );

    always_comb begin

    write = s_valid_i && s_ready_o;
    full  = wr_ptr == PTR_W'(T_DATA_RATIO - 1);
    send  = s_last_i || full;

    fifo_data_in = 'x;

        if (write) begin
            if (send) begin
                fifo_data_in[0]                       = s_last_i;
                fifo_data_in[T_DATA_RATIO:1]          = keep;
                fifo_data_in[FIFO_W-1:T_DATA_RATIO+1] = data;
            end
        end

        m_last_o = fifo_data_out[0];
        m_keep_o = fifo_data_out[T_DATA_RATIO:1];

        for (int i = 1; i < T_DATA_RATIO; i++) begin
            m_data_o[i] = fifo_data_out[T_DATA_RATIO+1+i*T_DATA_WIDTH-:T_DATA_WIDTH];
        end
    end

    always_ff @(posedge clk)
        if (~rst_n)
            wr_ptr <= '0;
        else if (send)
            wr_ptr <= '0;
        else if (write)
            wr_ptr <= wr_ptr + 1'b1;

    always_ff @(posedge clk)
        if (~rst_n)
            keep <= '0;
        else if (send)
            keep <= '0;
        else if (write)
            keep[wr_ptr] <= 1'b1;

    always_ff @(posedge clk)
        if (write)
            data[wr_ptr] <= s_data_i;

endmodule
