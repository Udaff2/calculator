`timescale 1 ns / 100 ps

parameter int IN_WIDTH                        = 4;
parameter int ANODE_WIDTH                     = 4;
parameter int SEGMENT_WIDTH                   = 8;
parameter int LED_WIDTH                       = 3;
parameter int NUMBER_OF_ARITHM_BUTTONS        = 4;
parameter int NUMBER_OF_ENTER_BUTTONS         = 2;
parameter int ERROR_VALUE                     = -1000;
parameter int ANODE_ERROR_VALUE               = -10;
parameter int DIGITAL_INTERPRETATION_ERROR    = -17;
parameter int ANODE_ASSERTION_ITERATION       = 1000;
parameter logic POINTER_OFFSET                = 10;

typedef enum logic [SEGMENT_WIDTH - 1 : 00] {
  ZERO               = 8'b11000000,
  ONE                = 8'b11111001,
  TWO                = 8'b10100100,
  THREE              = 8'b10110000,
  FOUR               = 8'b10011001,
  FIVE               = 8'b10010010,
  SIX                = 8'b10000010,
  SEVEN              = 8'b11111000,
  EIGHT              = 8'b10000000,
  NINE               = 8'b10010000,
  E                  = 8'b10000110,
  MINUS              = 8'b10111111,
  POINTED_ZERO       = 8'b01000000,
  POINTED_ONE        = 8'b01111001,
  POINTED_TWO        = 8'b00100100,
  POINTED_THREE      = 8'b00110000,
  POINTED_FOUR       = 8'b00011001,
  POINTED_FIVE       = 8'b00010010,
  POINTED_SIX        = 8'b00000010,
  POINTED_SEVEN      = 8'b01111000,
  POINTED_EIGHT      = 8'b00000000,
  POINTED_NINE       = 8'b00010000
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
logic                                     clk;
logic  [IN_WIDTH - 1:0]                   in_number = 4'b1111;
logic  [NUMBER_OF_ARITHM_BUTTONS - 1:0]   arithmetic_button = 4'b1111;
logic  [NUMBER_OF_ENTER_BUTTONS - 1:0]    enter_button = 2'b11;
//output
logic  [ANODE_WIDTH - 1: 0]    anodes;
logic  [SEGMENT_WIDTH - 1: 0]  segments;
logic  [LED_WIDTH - 1: 0]      led;
//local variables
int                            first_number = 0;
int                            second_number = 0;
int                            golden_result = 0;
logic  [ANODE_WIDTH: 0]        anode_check_value  = 1;
logic  [LED_WIDTH - 1: 0]      golden_led = 'b110;
logic                          devision_flag = 0;

event  finish_seg;

calculator black_box(
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
  
  
//main testbench
initial
  begin
    fork
      //all useful tasks
      begin
//        display_all_numbers(FIRST_NUMBER);
//        display_all_numbers(SECOND_NUMBER);
//        check_operation(PLUS);
        check_operation(SUBSTRACTION);
//        check_operation(MULTIPLICATION);
//        check_operation(DEVISION);
      end
       //Threads that infinitely check with @(clk)
//      forever begin 
//        @(segments)
////        @(posedge clk)
//        void'(digital_interpretation_of_segment());
//      end
      forever begin 
//        @(finish_seg)
        check_displayed_digit();
      end
      forever begin 
        check_led();
      end
    join_any
    disable fork;
    #10us;
    $finish;
  end
  
task create_number_for_tests( number_t first_or_second, logic [IN_WIDTH - 1:0] desirable_number);
  in_number = ~desirable_number;
  golden_result = desirable_number;
  #400us;
  case (first_or_second)
    FIRST_NUMBER   : begin
                       enter_button[0] = 0;
                       golden_led = 3'b101;
                       first_number = golden_result;
                       #400us;
                       enter_button[0] = 1;
                       #400us;
                     end
    SECOND_NUMBER  : begin
                       enter_button[1] = 0;
                       golden_led = 3'b011;
                       second_number = golden_result;
                       #400us;
                       enter_button[1] = 1;
                       #400us;
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
//      $display("%t, (golden result < 0) is  %d", $time, (golden_result < 0));
    end
  end
endtask





task press_and_unpress_arithmetic_button(arithmetic_t operation);
  devision_flag = 0;
  #400us;
  case (operation)
    PLUS            : begin
                        golden_result = first_number + second_number;
                        arithmetic_button[0] = 0;
                        golden_led = 3'b110;
                        #400us;
                        arithmetic_button[0] = 1;
                        golden_result [IN_WIDTH - 1:0] = ~in_number;
                        #400us;
                      end
    SUBSTRACTION    : begin
                        golden_result = first_number - second_number;
                        arithmetic_button[1] = 0;
                        golden_led = 3'b110;
                        #400us;
                        arithmetic_button[1] = 1;
                        golden_result [IN_WIDTH - 1:0] = ~in_number;
                        #400us;
                      end
    DEVISION        : begin
                        if (second_number == 0) begin
                          golden_result = ERROR_VALUE;
                        end
                        else begin
                          golden_result = (100 * first_number) 
                                          / second_number;
                          devision_flag = 1;
                        end
                        arithmetic_button[3] = 0;
                        golden_led = 3'b110;
                        #400us;
                        arithmetic_button[3] = 1;
                        golden_result [IN_WIDTH - 1:0] = ~in_number;
                        #400us;
                      end
    MULTIPLICATION  : begin
                        golden_result = first_number * second_number;
                        arithmetic_button[2] = 0;
                        golden_led = 3'b110;
                        #400us;
                        arithmetic_button[2] = 1;
                        golden_result [IN_WIDTH - 1:0] = ~in_number;
                        #400us;
                      end
  endcase
endtask

int golden_current_digit_int = 0;
int sign = 1;

function int golden_current_digit();
  sign = (golden_result < 0) ? -1 : 1;
  case (anodes)
    4'b1110  : begin
                 if (golden_result == ERROR_VALUE) begin
                   golden_current_digit_int = ERROR_VALUE;
                 end
                 else begin
                   golden_current_digit_int = 
                   sign * (golden_result % 10);
                 end
               end
    4'b1101  : begin
                 if (golden_result == ERROR_VALUE) begin
                   golden_current_digit_int = 0;
                 end
                 else begin
                   golden_current_digit_int = 
                   sign * ((golden_result / 10) % 10);
                 end
               end
    4'b1011  : begin
                 if (golden_result == ERROR_VALUE) begin
                   golden_current_digit_int = 0;
                 end
                 else if (devision_flag) begin
                   golden_current_digit_int = 
                   sign * ((golden_result / 100) % 10) + POINTER_OFFSET;
                 end
                 else begin
                   golden_current_digit_int = 
                   sign * ((golden_result / 100) % 10);
                 end
               end
    4'b0111  : begin
                 if (golden_result == ERROR_VALUE) begin
                   golden_current_digit_int = 0;
                 end
                 else if(sign > 0) begin
                   golden_current_digit_int = 
                    ((golden_result / 1000) % 10);
                 end
                 else begin
                   golden_current_digit_int = sign;
                 end
               end
    default :  begin
                golden_current_digit_int = ANODE_ERROR_VALUE;
               end
   endcase
endfunction



int digital_interpretation_of_segment_int = 0;

function digital_interpretation_of_segment();
//  static segment_t read_segment = segment_t'(segments);
//  static segment_t read_segment = segments;
  case (segments)
    ZERO            : begin
                        digital_interpretation_of_segment_int = 0;
                      end
    ONE             : begin
                        digital_interpretation_of_segment_int = 1;
                      end
    TWO             : begin
                        digital_interpretation_of_segment_int = 2;
                      end
    THREE           : begin
                        digital_interpretation_of_segment_int = 3;
                      end
    FOUR            : begin
                        digital_interpretation_of_segment_int = 4;
                      end
    FIVE            : begin
                        digital_interpretation_of_segment_int = 5;
                      end
    SIX             : begin
                        digital_interpretation_of_segment_int = 6;
                      end
    SEVEN           : begin
                        digital_interpretation_of_segment_int = 7;
                      end
    EIGHT           : begin
                        digital_interpretation_of_segment_int = 8;
                      end
    NINE            : begin
                        digital_interpretation_of_segment_int = 9;
                      end
    E               : begin
                        digital_interpretation_of_segment_int = ERROR_VALUE;
                      end
    MINUS           : begin
                        digital_interpretation_of_segment_int = -1;
                      end
    POINTED_ZERO    : begin
                        digital_interpretation_of_segment_int = 0 + POINTER_OFFSET;
                      end
    POINTED_ONE     : begin
                        digital_interpretation_of_segment_int = 1 + POINTER_OFFSET;
                      end
    POINTED_TWO     : begin
                        digital_interpretation_of_segment_int = 2 + POINTER_OFFSET;
                      end
    POINTED_THREE   : begin
                        digital_interpretation_of_segment_int = 3 + POINTER_OFFSET;
                      end
    POINTED_FOUR    : begin
                        digital_interpretation_of_segment_int = 4 + POINTER_OFFSET;
                      end
    POINTED_FIVE    : begin
                        digital_interpretation_of_segment_int = 5 + POINTER_OFFSET;
                      end
    POINTED_SIX     : begin
                        digital_interpretation_of_segment_int = 6 + POINTER_OFFSET;
                      end
    POINTED_SEVEN   : begin
                        digital_interpretation_of_segment_int = 7 + POINTER_OFFSET;
                      end
    POINTED_EIGHT   : begin
                        digital_interpretation_of_segment_int = 8 + POINTER_OFFSET;
                      end
    POINTED_NINE    : begin
                        digital_interpretation_of_segment_int = 9 + POINTER_OFFSET;
                      end
    default         : begin
                        digital_interpretation_of_segment_int = -DIGITAL_INTERPRETATION_ERROR;
                      end
  endcase
//  ->finish_seg;
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
    @(segments) begin
    void'(golden_current_digit());
    void'(digital_interpretation_of_segment());
    assert(golden_current_digit_int == digital_interpretation_of_segment_int)
      else $warning("%t, Displayed value is wrong!",$time);
  end
endtask



task check_led();
  @(led) begin
    assert(golden_led == led)
      else $warning("%t, Diods are wrong!",$time);
  end
endtask





endmodule 
