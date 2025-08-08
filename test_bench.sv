`timescale 1ns/1ps

module evm_tb;

  // Testbench signals
  reg clk;
  reg reset;
  reg [2:0] id;
  reg [1:0] option;
  wire varified;
  wire not_varified;
  wire vote_lock;

  // Instantiate the DUT
  evm dut (
    .clk(clk),
    .reset(reset),
    .id(id),
    .option(option),
    .varified(varified),
    .not_varified(not_varified),
    .vote_lock(vote_lock)
  );

  // Clock generation: 10 ns period
  always #5 clk = ~clk;

  initial begin
    // Dumping waveforms
    $dumpfile("evm_tb.vcd");
    $dumpvars(0, evm_tb);

    // Monitoring changes
    $monitor("T=%0t | ID=%0d | Option=%0d | Varified=%b | NotVarified=%b | VoteLock=%b",
             $time, id, option, varified, not_varified, vote_lock);

    // Initialize signals
    clk = 0;
    reset = 1;
    id = 3'b000;
    option = 2'b00;

    // Hold reset for a couple of cycles
    #6 reset = 0;
  end
  
  initial begin 

    // ----------------------
    // Test case 1: New voter
    // ----------------------
    #7
    id = 3'b001;   // Provide ID in IDEAL state
    #10;           // Wait 1 cycle for FSM to move to VERIFICATION
    option = 2'b10; // Provide option in VOTE state
    #10;

    // Finish simulation
    #50;
    $finish;
  end

endmodule
