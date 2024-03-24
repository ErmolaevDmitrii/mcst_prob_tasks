module mem
#(
    parameter MEM_SIZE = 6,
    parameter DATA_W = 10
)
(clk, rst, addr_w, write, data_in, addr_r, read, data_out);

    localparam ADDR_W = $clog2(MEM_SIZE);

    input clk;
    input rst;

    input write;
    input [ADDR_W - 1:0] addr_w;
    input [DATA_W - 1:0] data_in;

    input read;
    input [ADDR_W - 1:0] addr_r;
    output logic [DATA_W - 1:0] data_out;

    logic [DATA_W - 1:0] memory [0:MEM_SIZE - 1];

    integer i;

    always_ff @ (posedge clk, posedge rst)
    begin
        if (rst)
        begin
            for (i = 0; i < MEM_SIZE; i = i + 1)
                memory[i] <= 0;
        end
        else
        begin
            if (write & addr_w < MEM_SIZE)
                memory[addr_w] <= data_in;
            if (read & addr_r < MEM_SIZE)
                data_out <= memory[addr_r];
        end
    end

endmodule
