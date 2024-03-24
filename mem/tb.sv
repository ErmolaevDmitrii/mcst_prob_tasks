module testbench;

    int seed = 24;

    logic clk;

    initial
    begin
        clk = '0;
        forever
          # 10 clk = ~ clk;
    end

    logic rst;

    task reset;
        rst <= 'x;
        repeat (2) @ (posedge clk);
        rst <= '1;
        repeat (2) @ (posedge clk);
        rst <= '0;
    endtask

    localparam MEM_SIZE = 1000;
    localparam DATA_W   = 16;
    localparam ADDR_W = $clog2(MEM_SIZE);

    logic [ADDR_W - 1:0] addr_w;
    logic write;
    logic [DATA_W - 1:0] data_in;

    logic [ADDR_W - 1:0] addr_r;
    logic read;
    logic [DATA_W - 1:0] data_out;

    mem # (
        .DATA_W(DATA_W),
        .MEM_SIZE(MEM_SIZE)
    ) memory (
        .clk(clk), .rst(rst),
        .write(write), .addr_w(addr_w), .data_in(data_in),
        .read(read), .addr_r(addr_r), .data_out(data_out)
    );

    int unsigned mem_expected[MEM_SIZE];

    initial
    begin

        `ifdef __ICARUS__

            $dumpfile ("dump.vcd");
            $dumpvars;
        `endif

        reset();

        @ (posedge clk);
        write <= 1'b1;

        for(int unsigned i = 0; i < MEM_SIZE; i = i + 1)
        begin
            mem_expected[i] = $urandom(seed) & DATA_W'(32'hFFFFFFFF);
            data_in <= mem_expected[i];
            addr_w <= i;
            @ (posedge clk);
        end

        write <= 1'b0;
        read  <= 1'b1;

        for(int unsigned i = 0; i <= MEM_SIZE; i = i + 1)
        begin
            addr_r <= i;
            @ (posedge clk);
            if(i != 0)
            begin
                $display("%d %d", data_out, mem_expected[i - 1]);

                if(data_out != mem_expected[i - 1])
                begin
                    $display("FAIL");
                    $finish;
                end
            end
        end

        read <= 1'b0;
        @ (posedge clk);

        $display ("PASS");
        $finish;
    end

endmodule
