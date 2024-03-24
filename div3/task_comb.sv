module div_by_3_checker
#(
    parameter DATA_W = 8
)
(data, divisibility);

    input [DATA_W - 1:0] data;
    output divisibility;

    typedef enum logic[1:0] {
        MOD0,
        MOD1,
        MOD2
    } S;

    S div_bits [0:DATA_W - 1];

    always_comb
    begin
        if(data[DATA_W - 1]) div_bits[DATA_W - 1] = MOD1;
        else                 div_bits[DATA_W - 1] = MOD0;
    end

    always_comb
        for(int i = DATA_W - 2; i >= 0; i = i - 1)
        begin
            case(div_bits[i + 1])
                MOD0: if(data[i]) div_bits[i] = MOD1;
                      else        div_bits[i] = MOD0;
                MOD1: if(data[i]) div_bits[i] = MOD0;
                      else        div_bits[i] = MOD2;
                MOD2: if(data[i]) div_bits[i] = MOD2;
                      else        div_bits[i] = MOD1;
            endcase
        end

    assign divisibility = div_bits[0] == MOD0;

endmodule
