// RTL code for EVM
// assuming 8 people will vote for 4 candidates
module evm (
  input         clk,
  input         reset,       // synchronous reset in this example
  input  [2:0]  id,
  input  [1:0]  option,
  output reg    varified,
  output reg    not_varified,
  output reg    vote_lock
);

  // candidates (2-bit)
  localparam [1:0] A = 2'b00;
  localparam [1:0] B = 2'b01;
  localparam [1:0] C = 2'b10;
  localparam [1:0] D = 2'b11;

  // states (2-bit)
  localparam [1:0] IDEAL        = 2'b00;
  localparam [1:0] VERIFICATION = 2'b01;
  localparam [1:0] VOTE         = 2'b10;
  localparam [1:0] LOCKED       = 2'b11;

  // state and storage
  reg [1:0]  state;
  reg [2:0]  current_id;
  reg [7:0]  database;        // bit per voter: 1 => already voted
  reg [1:0]  option_storage;  // store chosen option (if needed)

  always @(posedge clk) begin
    if (reset) begin
      // synchronous reset
      varified       <= 1'b0;
      not_varified   <= 1'b0;
      vote_lock      <= 1'b0;
      state          <= IDEAL;
      option_storage <= 2'b00;
      database       <= 8'b0;    // reset all database bits
      current_id     <= 3'b0;
    end
    else begin
      case (state)
        IDEAL: begin
          // capture id and prepare for verification
          varified       <= 1'b0;
          not_varified   <= 1'b0;
          vote_lock      <= 1'b0;
          option_storage <= 2'b00;
          current_id     <= id;
          state          <= VERIFICATION;
        end

        VERIFICATION: begin
          if (database[current_id] == 1'b1) begin
            // already voted
            not_varified <= 1'b1;
            state        <= IDEAL;
          end
          else begin
            // mark as voted and allow voting
            database[current_id] <= 1'b1; // use non-blocking for sequential update
            varified <= 1'b1;
            state    <= VOTE;
          end
        end

        VOTE: begin
          option_storage <= option; // capture chosen option
          vote_lock      <= 1'b1;
          state          <= IDEAL;
        end

        default: begin
          state <= IDEAL;
        end
      endcase
    end
  end

endmodule
