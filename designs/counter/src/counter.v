`default_nettype none

module counter #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,      // Active-low asynchronous reset
    input  wire             enable,     // Enable counting
    input  wire             up_down,    // 1: Count Up, 0: Count Down
    input  wire [WIDTH-1:0] load_val,   // Value to load
    input  wire             load_en,    // Load enable
    output reg  [WIDTH-1:0] count,      // Counter output
    output wire             overflow    // High on maximum count in up mode
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= {WIDTH{1'b0}};
        end else if (load_en) begin
            count <= load_val;
        end else if (enable) begin
            if (up_down)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

    assign overflow = enable & up_down & (&count);

endmodule
`default_nettype wire
