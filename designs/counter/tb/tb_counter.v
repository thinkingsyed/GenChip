`timescale 1ns / 1ps

module tb_counter;

    parameter WIDTH = 8;

    reg             clk;
    reg             rst_n;
    reg             enable;
    reg             up_down;
    reg [WIDTH-1:0] load_val;
    reg             load_en;
    wire [WIDTH-1:0] count;
    wire            overflow;

    // Instantiate DUT (Device Under Test)
    counter #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .up_down(up_down),
        .load_val(load_val),
        .load_en(load_en),
        .count(count),
        .overflow(overflow)
    );

    // Clock generator: 100 MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Dump waveform for GTKWave / visual verification
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, tb_counter);

        // Initialize signals
        clk = 0;
        rst_n = 0;
        enable = 0;
        up_down = 1;
        load_val = 8'h00;
        load_en = 0;

        // Reset sequence
        #20;
        rst_n = 1;
        #10;

        // Test 1: Count Up
        $display("[TB] Test 1: Counting Up...");
        enable = 1;
        up_down = 1;
        #100;

        // Test 2: Count Down
        $display("[TB] Test 2: Counting Down...");
        up_down = 0;
        #50;

        // Test 3: Load Value & Overflow Check
        $display("[TB] Test 3: Load 0xFE and check overflow...");
        load_val = 8'hFE;
        load_en = 1;
        #10;
        load_en = 0;
        up_down = 1;
        #30;

        // Test 4: Asynchronous Reset Check
        $display("[TB] Test 4: Asynchronous Reset...");
        rst_n = 0;
        #10;
        if (count !== 8'h00) begin
            $display("[TB ERROR] Reset failed! Expected 0x00, got 0x%0h", count);
            $fatal(1);
        end
        rst_n = 1;
        #20;

        $display("========================================");
        $display("[TB SUCCESS] All counter tests passed!");
        $display("========================================");
        $finish;
    end

endmodule
