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
            shift_reg_1 <= {MAX_LENGTH{1'b0}};
            shift_reg_2 <= {MAX_LENGTH{1'b0}};
            pos <= 1'b0;
            neg <= 1'b0;
            corr <= 8'b0;
            corr_neg <= 8'b0;
            corr_pos <= 8'b0;
        end else begin
            // Shift in the new data
            shift_reg_1 <= {shift_reg_1[MAX_LENGTH-2:0], data_1};
            shift_reg_2 <= {shift_reg_2[MAX_LENGTH-2:0], data_2};
            corr <= corr + (data_1 ^ data_2) - (shift_reg_1[MAX_LENGTH - 1] ^ shift_reg_2[MAX_LENGTH - 1]) ;
            if (length > 1) begin
                corr_neg <= corr_neg + (shift_reg_1[0] ^ data_2) - (shift_reg_1[MAX_LENGTH - 1] ^ shift_reg_2[MAX_LENGTH - 2]);
                corr_pos <= corr_pos + (data_1 ^ shift_reg_2[0]) - (shift_reg_1[MAX_LENGTH - 2] ^ shift_reg_2[MAX_LENGTH - 1]);
            end


            // Determine if corr_neg or corr_pos is greater
            if (corr_neg < corr_pos) begin
                neg <= 1'b1;
                pos <= 1'b0;
            end else if (corr_pos < corr_neg) begin
                pos <= 1'b1;
                neg <= 1'b0;
            end else begin
                pos <= 1'b0;
                neg <= 1'b0;
            end
        end
    end
endmodule
