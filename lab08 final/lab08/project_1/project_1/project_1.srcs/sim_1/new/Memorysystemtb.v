`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: MemorySystem_tb
// Description: Testbench for addressDecoderTop
//              Tests:
//              1. Write to Data Memory and read back
//              2. Write to LEDs and verify output
//              3. Read from Switches
//              4. Verify only one enable fires at a time
//////////////////////////////////////////////////////////////////////////////////
module Memorysystemtb;

   
    reg         clk;
    reg         rst;
    reg  [31:0] address;
    reg         readEnable;
    reg         writeEnable;
    reg  [31:0] writeData;
    reg  [15:0] switches;

    // ================================================================
    //  DUT Outputs (observed by testbench)
    // ================================================================
    wire [31:0] readData;
    wire [15:0] leds;

    // ================================================================
    //  Instantiate DUT
    // ================================================================
    addressDecoderTop dut (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (switches),
        .readData   (readData),
        .leds       (leds)
    );

    // ================================================================
    //  Clock Generation: 100 MHz (10 ns period)
    // ================================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // ================================================================
    //  Task: Write to an address
    // ================================================================
    task do_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(negedge clk);         // apply before rising edge
            address     = addr;
            writeData   = data;
            writeEnable = 1;
            readEnable  = 0;
            @(posedge clk);         // write commits here
            #1;                     // small settle time
            writeEnable = 0;
        end
    endtask

    // ================================================================
    //  Task: Read from an address
    // ================================================================
    task do_read;
        input [31:0] addr;
        begin
            @(negedge clk);
            address     = addr;
            writeEnable = 0;
            readEnable  = 1;
            @(posedge clk);
            #1;
            readEnable  = 0;
        end
    endtask

    // ================================================================
    //  Test Results Counter
    // ================================================================
    integer pass_count;
    integer fail_count;

    // ================================================================
    //  Main Test Sequence
    // ================================================================
    initial begin
        // ---- Initialise ----
        pass_count  = 0;
        fail_count  = 0;
        rst         = 1;
        address     = 32'b0;
        readEnable  = 0;
        writeEnable = 0;
        writeData   = 32'b0;
        switches    = 16'b0;

        // Hold reset for 3 cycles
        repeat(3) @(posedge clk);
        #1;
        rst = 0;
        @(posedge clk);

        $display("============================================");
        $display("       MEMORY SYSTEM TESTBENCH START       ");
        $display("============================================");

        // ============================================================
        //  TEST GROUP 1: Data Memory (address[9:8] = 00)
        //  Address range 0 - 511
        // ============================================================
        $display("\n--- TEST GROUP 1: Data Memory Writes & Reads ---");

        // Test 1a: Write 0xDEADBEEF to address 0x00A (location 10)
        do_write(32'h00A, 32'hDEADBEEF);
        $display("T1a: Wrote 0xDEADBEEF to addr 0x00A");

        // Test 1b: Read back from address 0x00A
        do_read(32'h00A);
        if (readData === 32'hDEADBEEF) begin
            $display("T1b: PASS - readData = 0x%08X (expected 0xDEADBEEF)", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("T1b: FAIL - readData = 0x%08X (expected 0xDEADBEEF)", readData);
            fail_count = fail_count + 1;
        end

        // Test 1c: Write 0x12345678 to address 0x001 (location 1)
        do_write(32'h001, 32'h12345678);
        $display("T1c: Wrote 0x12345678 to addr 0x001");

        // Test 1d: Read back from address 0x001
        do_read(32'h001);
        if (readData === 32'h12345678) begin
            $display("T1d: PASS - readData = 0x%08X (expected 0x12345678)", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("T1d: FAIL - readData = 0x%08X (expected 0x12345678)", readData);
            fail_count = fail_count + 1;
        end

        // Test 1e: Write to address 0x001 doesn't corrupt address 0x00A
        do_read(32'h00A);
        if (readData === 32'hDEADBEEF) begin
            $display("T1e: PASS - addr 0x00A still holds 0xDEADBEEF after write to 0x001");
            pass_count = pass_count + 1;
        end else begin
            $display("T1e: FAIL - addr 0x00A corrupted, readData = 0x%08X", readData);
            fail_count = fail_count + 1;
        end

        // Test 1f: Write to last valid memory location (address 511 = 0x1FF)
        do_write(32'h1FF, 32'hCAFEBABE);
        do_read(32'h1FF);
        if (readData === 32'hCAFEBABE) begin
            $display("T1f: PASS - last memory location 0x1FF = 0x%08X", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("T1f: FAIL - last memory location 0x1FF = 0x%08X (expected 0xCAFEBABE)", readData);
            fail_count = fail_count + 1;
        end

        // ============================================================
        //  TEST GROUP 2: LED Peripheral (address[9:8] = 01)
        //  Address range 512 - 767  (0x200 - 0x2FF)
        // ============================================================
        $display("\n--- TEST GROUP 2: LED Peripheral Writes ---");

        // Test 2a: Write 0x00FF to LEDs
        do_write(32'h200, 32'h00FF);
        #2;
        if (leds === 16'h00FF) begin
            $display("T2a: PASS - LEDs = 0x%04X (expected 0x00FF)", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("T2a: FAIL - LEDs = 0x%04X (expected 0x00FF)", leds);
            fail_count = fail_count + 1;
        end

        // Test 2b: Write 0xAAAA to LEDs
        do_write(32'h200, 32'hAAAA);
        #2;
        if (leds === 16'hAAAA) begin
            $display("T2b: PASS - LEDs = 0x%04X (expected 0xAAAA)", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("T2b: FAIL - LEDs = 0x%04X (expected 0xAAAA)", leds);
            fail_count = fail_count + 1;
        end

        // Test 2c: Write 0x5555 to LEDs
        do_write(32'h200, 32'h5555);
        #2;
        if (leds === 16'h5555) begin
            $display("T2c: PASS - LEDs = 0x%04X (expected 0x5555)", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("T2c: FAIL - LEDs = 0x%04X (expected 0x5555)", leds);
            fail_count = fail_count + 1;
        end

        // Test 2d: LED write does NOT affect Data Memory
        do_read(32'h00A);
        if (readData === 32'hDEADBEEF) begin
            $display("T2d: PASS - Data Memory unaffected by LED write, addr 0x00A = 0x%08X", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("T2d: FAIL - Data Memory corrupted after LED write, addr 0x00A = 0x%08X", readData);
            fail_count = fail_count + 1;
        end

        // ============================================================
        //  TEST GROUP 3: Switch Peripheral (address[9:8] = 10)
        //  Address range 768 - 1023  (0x300 - 0x3FF)
        // ============================================================
        $display("\n--- TEST GROUP 3: Switch Peripheral Reads ---");

        // Test 3a: Read switches set to 0xABCD
        switches = 16'hABCD;
        do_read(32'h300);
        if (readData[15:0] === 16'hABCD) begin
            $display("T3a: PASS - readData[15:0] = 0x%04X (expected 0xABCD)", readData[15:0]);
            pass_count = pass_count + 1;
        end else begin
            $display("T3a: FAIL - readData[15:0] = 0x%04X (expected 0xABCD)", readData[15:0]);
            fail_count = fail_count + 1;
        end

        // Test 3b: Read switches set to 0x1234
        switches = 16'h1234;
        do_read(32'h300);
        if (readData[15:0] === 16'h1234) begin
            $display("T3b: PASS - readData[15:0] = 0x%04X (expected 0x1234)", readData[15:0]);
            pass_count = pass_count + 1;
        end else begin
            $display("T3b: FAIL - readData[15:0] = 0x%04X (expected 0x1234)", readData[15:0]);
            fail_count = fail_count + 1;
        end

        // Test 3c: Switch read does NOT affect LEDs
        #2;
        if (leds === 16'h5555) begin
            $display("T3c: PASS - LEDs unaffected by switch read, leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("T3c: FAIL - LEDs changed after switch read, leds = 0x%04X", leds);
            fail_count = fail_count + 1;
        end

        // ============================================================
        //  TEST GROUP 4: Address Decoder Isolation
        //  Verify only ONE enable fires per access
        // ============================================================
        $display("\n--- TEST GROUP 4: Decoder Isolation ---");

        // Test 4a: Writing to LED address must NOT write Data Memory
        //          Write 0xFFFFFFFF to LED address then read same
        //          offset in Data Memory - should still be 0
        do_write(32'h205, 32'hFFFFFFFF);  // LED address
        do_read(32'h005);                  // same offset in Data Memory
        if (readData !== 32'hFFFFFFFF) begin
            $display("T4a: PASS - LED write did not bleed into Data Memory (addr 0x005 = 0x%08X)", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("T4a: FAIL - LED write bled into Data Memory (addr 0x005 = 0x%08X)", readData);
            fail_count = fail_count + 1;
        end

        // Test 4b: readData should be 0 when no device is selected
        //          (neither readEnable nor writeEnable asserted)
        @(negedge clk);
        address     = 32'h000;
        readEnable  = 0;
        writeEnable = 0;
        @(posedge clk);
        #1;
        if (readData === 32'b0) begin
            $display("T4b: PASS - readData = 0 when no enable asserted");
            pass_count = pass_count + 1;
        end else begin
            $display("T4b: FAIL - readData = 0x%08X when no enable asserted (expected 0)", readData);
            fail_count = fail_count + 1;
        end

        // ============================================================
        //  TEST GROUP 5: Reset Behaviour
        // ============================================================
        $display("\n--- TEST GROUP 5: Reset ---");

        // Write something to LEDs, then reset, check LEDs cleared
        do_write(32'h200, 32'hFFFF);
        #2;
        rst = 1;
        repeat(2) @(posedge clk);
        #1;
        rst = 0;
        @(posedge clk);
        #1;
        if (leds === 16'h0000) begin
            $display("T5a: PASS - LEDs cleared after reset (leds = 0x%04X)", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("T5a: FAIL - LEDs not cleared after reset (leds = 0x%04X)", leds);
            fail_count = fail_count + 1;
        end

        // ============================================================
        //  SUMMARY
        // ============================================================
        $display("\n============================================");
        $display("  RESULTS: %0d PASSED  |  %0d FAILED", pass_count, fail_count);
        $display("============================================\n");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - check waveforms");

        $finish;
    end

    // ================================================================
    //  Waveform Dump (for GTKWave or Vivado simulator)
    // ================================================================
    initial begin
        $dumpfile("Memorysystemtb.vcd");
        $dumpvars(0, Memorysystemtb);
    end

    // ================================================================
    //  Timeout watchdog - stops simulation if it hangs
    // ================================================================
    initial begin
        #100000;
        $display("TIMEOUT: simulation did not finish in time");
        $finish;
    end

endmodule