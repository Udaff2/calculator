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
parameter int POINTER_OFFSET                  = 10;

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
  logic  [ANODE_WIDTH - 1: 0]               anodes;
  logic  [SEGMENT_WIDTH - 1: 0]             segments;
  logic  [LED_WIDTH - 1: 0]                 led;
//local variables
  int                                       first_number = 0;
  int                                       second_number = 0;
  int                                       golden_result = 0;
  logic  [LED_WIDTH - 1: 0]                 golden_led = 'b110;
  logic                                     devision_flag = 0;
  logic                                     need_to_check_flag = 1;
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
    forever #10 clk = ~clk;
  end
// main testbench
  initial
    begin
      fork
        begin
          check_operation(PLUS);
          check_operation(SUBSTRACTION);
          check_operation(MULTIPLICATION);
          check_operation(DEVISION);
//          repeat(100) begin
//            check_operation_on_random_numbers(arithmetic_t'($urandom_range(3,0)));
//          end
//          repeat(10) begin
//            check_forbidden_condition();
//          end
//          repeat(10) begin
//            check_operation_on_random_numbers(arithmetic_t'($urandom_range(3,0)));
//          end
        end
        forever begin
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

  task create_number_for_tests( number_t first_or_second,
  logic [IN_WIDTH - 1:0]    desirable_number);
    in_number = ~desirable_number;
    golden_result = desirable_number;
    #400us;
    case (first_or_second)
      FIRST_NUMBER : begin
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
    devision_flag = 0;
    #400us;
    case (operation)
      PLUS : begin
        golden_result = first_number + second_number;
        arithmetic_button[0] = 0;
        golden_led = 3'b110;
        #400us;
        arithmetic_button[0] = 1;
        golden_result = {28'h000000,~in_number};
        #400us;
      end
      SUBSTRACTION : begin
        golden_result = first_number - second_number;
        arithmetic_button[1] = 0;
        golden_led = 3'b110;
        #400us;
        arithmetic_button[1] = 1;
        golden_result = {28'h000000,~in_number};
        #400us;
      end
      DEVISION : begin
        if (second_number == 0) begin
          golden_result = ERROR_VALUE;
        end
        else begin
          golden_result = (100 * first_number) / second_number;
          devision_flag = 1;
        end
        arithmetic_button[3] = 0;
        golden_led = 3'b110;
        #400us;
        arithmetic_button[3] = 1;
        golden_result = {28'h000000,~in_number};
        devision_flag = 0;
        #400us;
      end
      MULTIPLICATION : begin
        golden_result = first_number * second_number;
        arithmetic_button[2] = 0;
        golden_led = 3'b110;
        #400us;
        arithmetic_button[2] = 1;
        golden_result = {28'h000000,~in_number};
        #400us;
      end
    endcase
  endtask

  task check_forbidden_condition;
    int random_time;
    //remember first_number
    in_number = $urandom_range(15,0);
    golden_result = {28'h000000,~in_number};
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[0] = 0;
   //making unpredictable entering_button
    enter_button[1] = $urandom_range(1,0); 
    golden_led = 3'b101;
    first_number = golden_result;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[0] = 1;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
   //remember second_number
    in_number = $urandom_range(15,0);
    golden_result = {28'h000000,~in_number};
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[1] = 0; 
   //making unpredictable entering_button
    enter_button[0] = $urandom_range(1,0); 
    golden_led = 3'b011;
    second_number = golden_result;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[1] = 1;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
   //making forbidden arithmetic_button
   need_to_check_flag = 0;
   arithmetic_button = $urandom_range(15,0);
   random_time = $urandom_range(350000, 4500000);
   #random_time;
   arithmetic_button = 4'b1111;
   need_to_check_flag = 1;
  endtask
  
  task check_operation_on_random_numbers(arithmetic_t operation);
    int random_time;
    //remember first_number
    in_number = $urandom_range(15,0);
    golden_result = {28'h000000,~in_number};
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[0] = 0; 
    golden_led = 3'b101;
    first_number = golden_result;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[0] = 1;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
   //remember second_number
    in_number = $urandom_range(15,0);
    golden_result = {28'h000000,~in_number};
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[1] = 0; 
    golden_led = 3'b011;
    second_number = golden_result;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    enter_button[1] = 1;
    random_time = $urandom_range(350000, 4500000);
    #random_time;
    //making operation
    devision_flag = 0;
    case (operation)
      PLUS : begin
        golden_result = first_number + second_number;
        arithmetic_button[0] = 0;
        golden_led = 3'b110;
        random_time = $urandom_range(350000, 4500000);
        #random_time;
        arithmetic_button[0] = 1;
        golden_result = {28'h000000,~in_number};
        random_time = $urandom_range(350000, 4500000);
        #random_time;
      end
      SUBSTRACTION : begin
        golden_result = first_number - second_number;
        arithmetic_button[1] = 0;
        golden_led = 3'b110;
        random_time = $urandom_range(350000, 4500000);
        #random_time;
        arithmetic_button[1] = 1;
        golden_result = {28'h000000,~in_number};
        random_time = $urandom_range(350000, 4500000);
        #random_time;
      end
      DEVISION : begin
        if (second_number == 0) begin
          golden_result = ERROR_VALUE;
        end
        else begin
          golden_result = (100 * first_number) / second_number;
          devision_flag = 1;
        end
        arithmetic_button[3] = 0;
        golden_led = 3'b110;
        random_time = $urandom_range(350000, 4500000);
        #random_time;
        arithmetic_button[3] = 1;
        golden_result = {28'h000000,~in_number};
        devision_flag = 0;
        random_time = $urandom_range(350000, 4500000);
        #random_time;
      end
      MULTIPLICATION : begin
        golden_result = first_number * second_number;
        arithmetic_button[2] = 0;
        golden_led = 3'b110;
        random_time = $urandom_range(350000, 4500000);
        #random_time;
        arithmetic_button[2] = 1;
        golden_result = {28'h000000,~in_number};
        random_time = $urandom_range(350000, 4500000);
        #random_time;
      end
    endcase
  endtask
  
  int golden_current_digit_int = 0;

  function automatic int golden_current_digit();
    int sign = (golden_result < 0) ? -1 : 1;
    case (anodes)
      4'b1110 : begin
        if (golden_result == ERROR_VALUE) begin
          golden_current_digit_int = ERROR_VALUE;
        end
        else begin
          golden_current_digit_int = sign * (golden_result % 10);
        end
      end
      4'b1101 : begin
        if (golden_result == ERROR_VALUE) begin
          golden_current_digit_int = 0;
        end
        else begin
          golden_current_digit_int = sign * ((golden_result / 10) % 10);
        end
      end
      4'b1011 : begin
        if (golden_result == ERROR_VALUE) begin
          golden_current_digit_int = 0;
        end
        else if (devision_flag == 1) begin
          golden_current_digit_int = sign * ((golden_result / 100) % 10)
          + POINTER_OFFSET;
        end
        else begin
          golden_current_digit_int = sign * ((golden_result / 100) % 10);
        end
      end
      4'b0111 : begin
        if (golden_result == ERROR_VALUE) begin
          golden_current_digit_int = 0;
        end
        else if(sign > 0) begin
          golden_current_digit_int = ((golden_result / 1000) % 10);
        end
        else begin
          golden_current_digit_int = sign;
        end
      end
      default : begin
        golden_current_digit_int = ANODE_ERROR_VALUE;
      end
    endcase
  endfunction

  int digital_interpretation_of_segment_int = 0;

  function digital_interpretation_of_segment();
    case (segments)
      ZERO         : digital_interpretation_of_segment_int = 0;
      ONE          : digital_interpretation_of_segment_int = 1;
      TWO          : digital_interpretation_of_segment_int = 2;
      THREE        : digital_interpretation_of_segment_int = 3;
      FOUR         : digital_interpretation_of_segment_int = 4;
      FIVE         : digital_interpretation_of_segment_int = 5;
      SIX          : digital_interpretation_of_segment_int = 6;
      SEVEN        : digital_interpretation_of_segment_int = 7;
      EIGHT        : digital_interpretation_of_segment_int = 8;
      NINE         : digital_interpretation_of_segment_int = 9;
      E            : digital_interpretation_of_segment_int = ERROR_VALUE;
      MINUS        : digital_interpretation_of_segment_int = -1;
      POINTED_ZERO : digital_interpretation_of_segment_int = 0 + POINTER_OFFSET;
      POINTED_ONE  : digital_interpretation_of_segment_int = 1 + POINTER_OFFSET;
      POINTED_TWO  : digital_interpretation_of_segment_int = 2 + POINTER_OFFSET;
      POINTED_THREE: digital_interpretation_of_segment_int = 3 + POINTER_OFFSET;
      POINTED_FOUR : digital_interpretation_of_segment_int = 4 + POINTER_OFFSET;
      POINTED_FIVE : digital_interpretation_of_segment_int = 5 + POINTER_OFFSET;
      POINTED_SIX  : digital_interpretation_of_segment_int = 6 + POINTER_OFFSET;
      POINTED_SEVEN: digital_interpretation_of_segment_int = 7 + POINTER_OFFSET;
      POINTED_EIGHT: digital_interpretation_of_segment_int = 8 + POINTER_OFFSET;
      POINTED_NINE : digital_interpretation_of_segment_int = 9 + POINTER_OFFSET;
      default      : digital_interpretation_of_segment_int =
      DIGITAL_INTERPRETATION_ERROR;
    endcase
  endfunction

  task check_displayed_digit();
    @(segments) begin
      if(1) begin
        void'(golden_current_digit());
        void'(digital_interpretation_of_segment());
        assert(golden_current_digit_int === digital_interpretation_of_segment_int)
        else $warning("%t, Displayed value is wrong!",$time);
      end
    end
  endtask

  task check_led();
    @(led) begin
      if(1) begin
        assert(golden_led == led)
          else $warning("%t, Diods are wrong!",$time);
      end
    end
  endtask

endmodule
