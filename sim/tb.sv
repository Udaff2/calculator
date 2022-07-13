`timescale 1 ns / 100 ps

parameter int IN_WIDTH       = 4;
parameter int ANODE_WIDTH    = 4;
parameter int SEGMENT_WIDTH  = 7;
parameter int LED_WIDTH      = 3;
parameter int ERROR_VALUE    = -1000;
parameter int ANODE_ERROR_VALUE = -10;

typedef enum logic [SEGMENT_WIDTH - 1 : 00] {
  ZERO       = 7'b1111110,
  ONE        = 7'b0110000,
  TWO        = 7'b1101101,
  THREE      = 7'b1111001,
  FOUR       = 7'b0110011,
  FIVE       = 7'b1011011,
  SIX        = 7'b1011111,
  SEVEN      = 7'b1110000,
  EIGHT      = 7'b1111111,
  NINE       = 7'b1111011,
  E          = 7'b1001111,
  MINUS      = 7'b0000001
} segment_t;

typedef enum {
  FIRST_NUMBER   = 1,
  SECOND_NUMBER  = 2
} number_t;

typedef enum {
  PLUS           = 1,
  SUBSTRACTION   = 2,
  DEVISION       = 3,
  MULTIPLICATION = 4
} arithmetic_t;



module tb();


//input
reg                 clk;
reg                 [IN_WIDTH - 1:0] in_number = 0;
reg                 plus_key = 0;
reg                 substract_key = 0;
reg                 devide_key = 0;
reg                 multiply_key = 0;
reg                 k_1 = 0;
reg                 k_2 = 0;
//output
wire                [ANODE_WIDTH - 1: 0] anode;
wire                [SEGMENT_WIDTH - 1: 0] seg;
wire                [LED_WIDTH - 1: 0] led;
//local variables
int                 first_number = 0;
int                 second_number = 0;
int                 golden_result = 0;
logic               [ANODE_WIDTH: 0] anode_check_value  = 1;
logic               [LED_WIDTH - 1: 0] golden_led = 'b001;

top black_box(
   .clk            (clk),
   .in_number      (in_number),
   .plus_key       (plus_key),
   .substract_key  (substract_key),
   .devide_key     (devide_key),
   .multiply_key   (multiply_key),
   .k_1            (k_1),
   .k_2            (k_2),
   .anode          (anode),
   .seg            (seg),
   .led            (led)
);

  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // Generate clock signal 10 MHz
  end

  
//main testbench
initial
  begin
    fork
      //all useful tasks
      begin
        check_operation( PLUS );
      end
       //Threads that infinitely check with @(anode)
//      forever begin 
//        check_anode_signal();
//      end
//      forever begin 
//        check_displayed_digit();
//      end
//      forever begin 
//        check_led();
//      end
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
                       k_1 = 1;
                       #400us;
                       k_1 = 0;
                       first_number = in_number;
                       golden_led = 3'b010;
                     end
    SECOND_NUMBER  : begin
                       k_2 = 1;
                       #400us;
                       k_2 = 0;
                       second_number = in_number;
                       golden_led = 3'b100;
                     end
  endcase
endtask



task display_all_numbers(number_t number);
  $display("%t, displaying all possible numbers", $time);
  for (int i = 0; i < (1 << IN_WIDTH);i++) begin
    create_number_for_tests(number, i);
  end
endtask



task check_operation(arithmetic_t operation);
  $display("%t, Checking operation %S", $time, operation_str(operation));
  for (int i = 0; i < (1 << IN_WIDTH);i++) begin
    create_number_for_tests(FIRST_NUMBER, i);
    for (int i = 0; i < (1 << IN_WIDTH);i++) begin
      create_number_for_tests(SECOND_NUMBER, i);
      press_and_unpress_arithmetic_button(operation);
    end
  end
endtask



function string operation_str(arithmetic_t operation);
  case (operation)
    PLUS            : begin
                        operation_str = "PLUS";
                      end
    SUBSTRACTION    : begin
                        operation_str = "SUBSTRACTION";
                      end
    DEVISION        : begin
                        operation_str = "DEVISION";
                      end
    MULTIPLICATION  : begin
                        operation_str = "MULTIPLICATION";
                      end
  endcase
endfunction



task press_and_unpress_arithmetic_button(arithmetic_t operation);
  #400us;
  case (operation)
    PLUS            : begin
                        golden_result = first_number + second_number;
                        plus_key = 1;
                        #400us;
                        plus_key = 0;
                      end
    SUBSTRACTION    : begin
                        golden_result = first_number - second_number;
                        substract_key = 1;
                        #400us;
                        substract_key = 0;
                      end
    DEVISION        : begin
                        golden_result = ((second_number == 0) ? ERROR_VALUE : (first_number / second_number)); 
                        devide_key = 1;
                        #400us;
                        devide_key = 0;
                      end
    MULTIPLICATION  : begin
                        golden_result = first_number * second_number;
                        multiply_key = 1;
                        #400us;
                        multiply_key = 0;
                      end
  endcase
  golden_led = 3'b001;
endtask



function int golden_current_digit();
static logic sign = (golden_result > 0) ? 1 : -1;
  case (anode)
    'b0001  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? ERROR_VALUE : (sign * (golden_result % 10));
              end
    'b0010  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : (sign * ((golden_result / 10) % 10));
              end
    'b0100  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : (sign * ((golden_result / 100) % 10));
              end
    'b1000  : begin
              golden_current_digit= (golden_result == ERROR_VALUE) ? 0 : 
                                                                        (golden_result > 0) ? 0 : -1;
              end
    default : begin
                golden_current_digit = ANODE_ERROR_VALUE;
              end
   endcase
endfunction




function digital_interpretation_of_segment();
  static segment_t read_segment = segment_t'(seg);
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


task check_anode_signal(); // TODO
  @(anode) begin
    if(anode == anode_check_value) begin
      anode_check_value = anode_check_value << 1;
      if(anode_check_value == (1 << ANODE_WIDTH))
        begin
          anode_check_value = 1;
        end
    end
    else begin
      $warning("%t, Anode signal is wrong!", $time);
    end
  end
endtask




task check_displayed_digit();
  @(anode) begin
    assert(golden_current_digit() == digital_interpretation_of_segment())
      else $warning("%t, Displayed value is wrong!",$time);
  end
endtask



task check_led();
  @(anode) begin
    assert(golden_led == led)
      else $warning("%t, Diods are wrong!",$time);
  end
endtask



endmodule 