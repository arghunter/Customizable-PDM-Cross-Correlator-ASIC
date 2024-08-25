module buffer #(
    parameter MAX_LENGTH = 256
)(
    input wire clk,            // System clock
    input wire rst,            // Reset signal
    input wire data_1,         // Input data for the first shift register
    input wire data_2,         // Input data for the second shift register
    input wire [7:0] length,   // Length of the shift registers
    output reg [7:0] corr,     // Output sum of ones after XOR
    output reg pos,
    output reg neg
);

    reg [MAX_LENGTH-1:0] shift_reg_1;
    reg [MAX_LENGTH-1:0] shift_reg_2;
    reg [7:0] corr_neg;
    reg [7:0] corr_pos;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            corr <= 8'b0;
            corr_neg <= 8'b0;
            corr_pos <= 8'b0;
            shift_reg_1 <= {MAX_LENGTH{1'b0}};
            shift_reg_2 <= {MAX_LENGTH{1'b0}};
            pos <= 1'b0;
            neg <= 1'b0;
        end else begin
            // Shift in the new data
            shift_reg_1 <= {shift_reg_1[MAX_LENGTH-2:0], data_1};
            shift_reg_2 <= {shift_reg_2[MAX_LENGTH-2:0], data_2};

            // Initialize corr, corr_neg, and corr_pos to 0 for this cycle
            corr = 8'b0;
            corr_neg = 8'b0;
            corr_pos = 8'b0;

            // Calculate the XOR and count the number of ones
            for (i = 0; i < length; i = i + 1) begin
                corr = corr + (shift_reg_1[i] ^ shift_reg_2[i]);
                if (i != 0) begin
                    corr_neg = corr_neg + (shift_reg_1[i] ^ shift_reg_2[i-1]);
                end
                if (i != length-1) begin
                    corr_pos = corr_pos + (shift_reg_1[i] ^ shift_reg_2[i+1]);
                end
            end

            // Determine if corr_neg or corr_pos is greater
            if (corr_neg < corr_pos) begin
                neg = 1;
                pos = 0;
            end else if (corr_pos < corr_neg) begin
                pos = 1;
                neg = 0;
            end else begin
                pos = 0;
                neg = 0;
            end
        end
    end
endmodule
