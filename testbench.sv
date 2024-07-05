module testbench;
    parameter WIDTH = 4;
    parameter RATIO = 2;

    parameter CLK_PERIOD = 10;

    // typedef struct {
    //     logic [WIDTH-1:0] data;
    //     logic             last;
    // } upsize_in_t;
    //
    // typedef struct {
    //     logic [WIDTH-1:0] data [RATIO-1:0];
    //     logic [RATIO-1:0] keep;
    //     logic             last;
    // } upsize_out_t;
    //
    // mailbox#(upsize_in_t)  mbx_in  = new();
    // mailbox#(upsize_out_t) mbx_out = new();

    logic             clk;
    logic             rst_n;
    logic [WIDTH-1:0] s_data;
    logic             s_last;
    logic             s_valid;
    logic             s_ready;
    logic [WIDTH-1:0] m_data [RATIO-1:0];
    logic [RATIO-1:0] m_keep;
    logic             m_last;
    logic             m_valid;
    logic             m_ready;

    stream_upsize #(
        .T_DATA_WIDTH (WIDTH),
        .T_DATA_RATIO (RATIO)
    ) dut (
        .clk       ( clk     ),
        .rst_n     ( rst_n   ),
        .s_data_i  ( s_data  ),
        .s_last_i  ( s_last  ),
        .s_valid_i ( s_valid ),
        .s_ready_o ( s_ready ),
        .m_data_o  ( m_data  ),
        .m_keep_o  ( m_keep  ),
        .m_last_o  ( m_last  ),
        .m_valid_o ( m_valid ),
        .m_ready_i ( m_ready )
    );

    event e;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        ->e;
    end

    always @(e) begin
        forever begin
            drive_input();
            drive_output();
        end
    end

    initial begin
        repeat (300) @(posedge clk);
        $finish();
    end

    initial begin
        clk = 0;
        forever begin
            clk = ~ clk;
            #(CLK_PERIOD/2);
        end
    end

    task drive_input();
        forever begin
            int delay = $urandom(10);
            repeat (delay) @(posedge clk);
            s_data <= WIDTH'($urandom());
            s_last <= $urandom_range(0, 100) > 75 ? 1 : 0;
            s_valid <= 1'b1;

            while (~s_ready)
                @(posedge clk);

            s_valid <= 1'b0;
        end
    endtask

    task drive_output();
        forever begin
            int delay = $urandom(10);
            repeat (delay) @(posedge clk);
            m_ready <= 1'b1;

            while (~m_valid)
                @(posedge clk);

            m_ready <= 1'b0;
        end
    endtask

    // task monitor();
    //     upsize_in_t  in;
    //     upsize_out_t out;
    //
    //     if (s_valid && s_ready) begin
    //         in.data = s_data;
    //         in.keep = s_keep;
    //         mbx_in.put(s_data);
    //     end
    //
    //     if (m_valid && m_ready)
    //         mbx_out.put(m_data);
    // endtask

    initial begin
        rst_n = 0;
        #(CLK_PERIOD*10);
        rst_n = 1;
    end

endmodule
