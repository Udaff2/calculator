`timescale 1 ns / 100 ps

parameter int IN_WIDTH                  = 4;
parameter int ANODE_WIDTH               = 4;
parameter int SEGMENT_WIDTH             = 8;
parameter int LED_WIDTH                 = 3;
parameter int NUMBER_OF_ARITHM_BUTTONS  = 4;
parameter int NUMBER_OF_ENTER_BUTTONS   = 2;
parameter int ERROR_VALUE               = -1000;
parameter int ANODE_ERROR_VALUE         = -10;
parameter int ANODE_ASSERTION_ITERATION = 1000;
parameter int DEVIDER_WIDTH             = 12;

typedef enum logic [SEGMENT_WIDTH - 1 : 00] {
  ZERO       = 8'b11000000,
  ONE        = 8'b11111001,
  TWO        = 8'b10100100,
  THREE      = 8'b10110000,
  FOUR       = 8'b10011001,
  FIVE       = 8'b10010010,
  SIX        = 8'b10000010,
  SEVEN      = 8'b11111000,
  EIGHT      = 8'b10000000,
  NINE       = 8'b10010000,
  E          = 8'b10000110,
  MINUS      = 8'b10111111
} segment_t;

typedef enum {
  FIRST_NUMBER   = 0,
  SECOND_NUMBER  = 1
} number_t;

typedef enum {
  PLUS            = 0,
  SUBSTRACTION    = 1,
  MULTIPLICATION  = 2,
  DEVISION        = 3
} arithmetic_t;



module tb();


//input
reg                                     clk;
reg  [IN_WIDTH - 1:0]                   in_number = 0;
reg  [NUMBER_OF_ARITHM_BUTTONS - 1:0]   arithmetic_button = 4'b0000;
reg  [NUMBER_OF_ENTER_BUTTONS- 1:0]     enter_button = 2'b00;
//output
wire  [ANODE_WIDTH - 1: 0]    anodes;
wire  [SEGMENT_WIDTH - 1: 0]  segments;
wire  [LED_WIDTH - 1: 0]      led;
//local variables
int                            first_number = 0;
int                            second_number = 0;
int                            golden_result = 0;
logic  [ANODE_WIDTH: 0]        anode_check_value  = 1;
logic  [LED_WIDTH - 1: 0]      golden_led = 'b110;
logic  [DEVIDER_WIDTH - 1: 0]  devider = 0;

top black_box(
   .clk            (clk),
   .in_number      (in_number),
   .arif           (arithmetic_button),
   .key            (enter_button),
   .anodes         (anodes),
   .segments       (segments),
   .led            (led)
);

  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // Generate clock signal 50 MHz
  end
  
  //devider
  initial begin
    forever begin
      @(posedge clk) devider <= devider + 1;
    end
  end
  
//main testbench
initial
  begin
    fork
      //all useful tasks
      begin
        display_all_numbers(FIRST_NUMBER);
        display_all_numbers(SECOND_NUMBER);
        check_operation(PLUS);
        check_operation(SUBSTRACTION);
        check_operation(MULTIPLICATION);
        check_operation(DEVISION);
      end
       //Threads that infinitely check with @(clk)
      //forever begin 
      //  check_displayed_digit();
      //end
      forever begin 
        check_led();
      end
    join_any
    disable fork;
    #10us;
    $finish;
  end
  
task create_number_for_tests( number_t first_or_second, int desirable_number);
  in_number = desirable_number;
  golden_result = desirable_number;
  #400us;
  case (first_or_second)
    FIRST_NUMBER   : begin
                       enter_button[0] = 1;
                       golden_led = 3'b101;
                       first_number = in_number;
                       #400us;
                       enter_button[0] = 0;
                       #400us;
                     end
    SECOND_NUMBER  : begin
                       enter_button[1] = 1;
                       golden_led = 3'b011;
                       second_number = in_number;
                       #400us;
                       enter_button[1] = 0;
                     end
  endcase
endtask



task display_all_numbers(number_t number);
  $display("%t, Displaying all possible numbers making %S ", $time, number.name());
  for (int i = 0; i < (1 << IN_WIDTH);i++) begin
    create_number_for_tests(number, i);
  end
endtask



task check_operation(arithmetic_t operation);
  $display("%t, Checking operation %S", $time, operation.name());
  for (int i = 0; i < (1 << IN_WIDTH);i++) begin
    create_number_for_tests(FIRST_NUMBER, i);
    for (int i = 0; i < (1 << IN_WIDTH);i++) begin
      create_number_for_tests(SECOND_NUMBER, i);
      press_and_unpress_arithmetic_button(operation);
    end
  end
endtask





task press_and_unpress_arithmetic_button(arithmetic_t operation);
  #400us;
  case (operation)
    PLUS            : begin
                        golden_result = first_number + second_number;
                        arithmetic_button[0] = 1;
                        golden_led = 3'b001;
                        #400us;
                        arithmetic_button[0] = 0;
                        #400us;
                      end
    SUBSTRACTION    : begin
                        golden_result = first_number - second_number;
                        arithmetic_button[1] = 1;
                        golden_led = 3'b001;
                        #400us;
                        arithmetic_button[1] = 0;
                        #400us;
                      end
    DEVISION        : begin
                        golden_result = ((second_number == 0) ? ERROR_VALUE : (first_number / second_number)); 
                        arithmetic_button[3] = 1;
                        golden_led = 3'b001;
                        #400us;
                        arithmetic_button[3] = 0;
                        #400us;
                      end
    MULTIPLICATION  : begin
                        golden_result = first_number * second_number;
                        arithmetic_button[2] = 1;
                        golden_led = 3'b001;
                        #400us;
                        arithmetic_button[2] = 0;
                        #400us;
                      end
  endcase
endtask

function int golden_current_digit();
static int sign = (golden_result >= 0) ? 1 : -1;
  case (anodes)
    4'b1110  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? ERROR_VALUE : (sign * (golden_result % 10));
              end
    4'b1101  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : (sign * ((golden_result / 10) % 10));
              end
    4'b1011  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : (sign * ((golden_result / 100) % 10));
              end
    4'b0111  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : 
                                                                        (golden_result >= 0) ? 0 : -1;
              end
    default : begin
                golden_current_digit = ANODE_ERROR_VALUE;
              end
   endcase
endfunction




function digital_interpretation_of_segment();
  static segment_t read_segment = segment_t'(segments);
  case (read_segment)
    ZERO            : begin
                        digital_interpretation_of_segment = 0;
                      end
    ONE             : begin
                        digital_interpretation_of_segment = 1;
                      end
    TWO             : begin
                        digital_interpretation_of_segment = 2;
                      end
    THREE           : begin
                        digital_interpretation_of_segment = 3;
                      end
    FOUR            : begin
                        digital_interpretation_of_segment = 4;
                      end
    FIVE            : begin
                        digital_interpretation_of_segment = 5;
                      end
    SIX             : begin
                        digital_interpretation_of_segment = 6;
                      end
    SEVEN           : begin
                        digital_interpretation_of_segment = 7;
                      end
    EIGHT           : begin
                        digital_interpretation_of_segment = 8;
                      end
    NINE            : begin
                        digital_interpretation_of_segment = 9;
                      end
    E               : begin
                        digital_interpretation_of_segment = ERROR_VALUE;
                      end
    MINUS           : begin
                        digital_interpretation_of_segment= - 1;
                      end
  endcase
endfunction
//
//
//task check_anode_signal(); // TODO
//  @(anodes) begin
//    if(anodes == ~anode_check_value) begin
//      anode_check_value = anode_check_value << 1;
//      if(anode_check_value == (1 << ANODE_WIDTH))
//        begin
//          anode_check_value = 1;
//        end
//    end
//    else begin
//      $warning("%t, Anode signal is wrong!", $time);
//    end
//  end
//endtask




task check_displayed_digit();
  @(clk) begin
    assert(golden_current_digit() == digital_interpretation_of_segment())
      else $warning("%t, Displayed value is wrong!",$time);
  end
endtask



task check_led();
  @(clk) begin
    assert(golden_led == led)
      else $warning("%t, Diods are wrong!",$time);
  end
endtask





sequence anode_seq;
  (anodes == 4'b1110) ##1 (anodes == 4'b1101) ##1 (anodes == 4'b1011) ##1 (anodes == 4'b0111);
endsequence

property anode_signal_property;
  @(posedge devider[11])
    anode_seq [*ANODE_ASSERTION_ITERATION];
endproperty


initial begin
  my_assertion: assume property (anode_signal_property) else $display("%t, anode signal is wrong, anode = %d", $time, anodes);
end


endmodule 
