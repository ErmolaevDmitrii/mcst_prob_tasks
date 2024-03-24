module testbench;

    int seed = 24;

    localparam DATA_W   = 16;

    logic[DATA_W - 1:0] data;
    logic div;

    div_by_3_checker # (
        .DATA_W(DATA_W)
    ) sd3 (
        .data(data), .divisibility(div)
    );

    logic expected_div;
    int unsigned i;

    initial
    begin

        `ifdef __ICARUS__

            $dumpfile ("dump.vcd");
            $dumpvars;
        `endif

        repeat(1000)
        begin
            i = $urandom(seed) & DATA_W'(32'hFFFFFFFF);
            data = i;
            #10;
            expected_div = i % 3 == 0;
            $display("%d %b (expected %b)", i, div, expected_div);

            if(div != expected_div)
            begin
                $display("FAIL");
                $finish;
            end
        end

        $display ("PASS");
        $finish;
    end

endmodule
