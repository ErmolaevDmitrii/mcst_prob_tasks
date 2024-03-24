module div_by_3_checker(
    input clk,
    input rst,

    input [7:0] data,
    input       data_vld,

    output logic div_by_3,
    output logic div_by_3_vld
);

    enum logic[2:0] {
        IDLE,
        MOD0,
        MOD1,
        MOD2,
        END
    } state, new_state;

    logic[7:0] loaded_data;
    wire current_bit = loaded_data[7];
    assign div_by_3_vld = new_state == IDLE;

    always_comb
    begin
        new_state = state;

        case (state)
            IDLE: if(data_vld)            new_state = MOD0;
                  else                    new_state = IDLE;
            MOD0: if(loaded_data == 8'd0) new_state = END;
                  else if(current_bit)    new_state = MOD1;
                  else                    new_state = MOD0;
            MOD1: if(loaded_data == 8'd0) new_state = END;
                  else if(current_bit)    new_state = MOD0;
                  else                    new_state = MOD2;
            MOD2: if(loaded_data == 8'd0) new_state = END;
                  else if(current_bit)    new_state = MOD2;
                  else                    new_state = MOD1;
            END:  new_state = IDLE;
        endcase
    end

    always_ff @ (posedge clk)
    begin
        if(rst)
        begin
            state <= IDLE;
            loaded_data <= 8'd255;
        end
        else
        begin
            if(state == IDLE & data_vld) loaded_data <= data;
            else if(state == IDLE) loaded_data <= 8'd255;
            else                   loaded_data <= loaded_data << 1;

            state <= new_state;
        end
    end

    //always_ff @ (posedge clk)
    //begin
    //    if (rst) div_by_3 <= 1'b0;
    //    else if(new_state == END) div_by_3 <= state == MOD0;
    //end

    always_latch
    begin
        if(new_state == END) div_by_3 <= state == MOD0;
    end

endmodule

module testbench;

    int seed = 41;
    byte unsigned rand_num;

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

    logic [7:0] data;
    logic data_valid;

    logic divisibility;
    logic div_valid;

    div_by_3_checker sd3(
    .data(data),
    .data_vld(data_valid),
    .clk(clk),
    .rst(rst),
    .div_by_3(divisibility),
    .div_by_3_vld(div_valid),
    .*);

  logic expected_div_by_3;

  initial
  begin
    `ifdef __ICARUS__

        $dumpfile ("dump.vcd");
        $dumpvars;
    `endif

    reset();
    repeat (1000)
    begin

        data_valid <= 1'b0;

        @ (posedge clk);
        # 1

        rand_num = $urandom(seed);
        data <= rand_num;
        data_valid <= 1'b1;
        @ (posedge clk);
        data_valid <= 1'b0;

        while(~ div_valid) begin
            @ (posedge clk);
        end

        @ (posedge clk);
        @ (posedge clk);
        #1

        expected_div_by_3 = (rand_num % 3) == 0;

        $display("num %d, div3 %b (expected %b)",
          rand_num,
          divisibility, expected_div_by_3);

        if(expected_div_by_3 != divisibility) begin
            $display ("FAIL");
            $finish;
        end
    end
    $display ("PASS");
    $finish;
  end

endmodule
