/*
Confuigures the MAX30102 on the MAXREFDES117 eval board for SPO2 mode
Samples at 50 Hz and plots graph using serial plotter. Samples are polled. 

basis for design from https://github.com/DFRobot/DFRobot_MAX30102

datasheet for MAX30102: https://cdn.sparkfun.com/assets/8/3/c/3/2/MAX30102_Datasheet.pdf
*/

#include <Wire.h>

void setup()
{
  Wire.begin();        // start I2C bus
  Serial.begin(9600);  // start the Serial interface
  Serial.println("I2C and serial interfaces are up!");

  // test config function 
  MAX30102_config(50, 4, 200, 411, 4096);

  // debug block to print out all values of the register map
  uint8_t reg = 0;
  uint8_t addr = 0;

  for(int i = 0; i < 48; i++)
  {
    addr = i;
    reg = read_reg(0x57, addr);
    Serial.print("Register Address ");
    Serial.print(addr, HEX);
    Serial.print(" holds binary data 0b");
    for (int i = 7; i >= 0; i--) {
      Serial.print(bitRead(reg, i));
    }
    Serial.println();
  }

  // // print reg contents in binary
  // Serial.print("fifo_config register contents are: ");
  // for (int i = 7; i >= 0; i--) {
  //     Serial.print(bitRead(fifo_config, i));
  //   }
  // Serial.println();

  
}

void write_reg(uint8_t device_addr, uint8_t reg_addr, uint8_t data)
{
  // See "Write Data Format" in datasheet
  // send slave ID first, register address, and then one or more data bytes (this function configured for one)
  Wire.beginTransmission(device_addr);
  Wire.write(reg_addr);
  Wire.write(data);
  Wire.endTransmission();
}

uint8_t read_reg(uint8_t device_addr, uint8_t reg_addr)
{
  // read status of interrupts
  /*
    - for a read, first comes slave ID, then register address
    - next, a stop condition occurs
    - finally, a new transmission is started and the slave ID goes first. The data follows and can be read
  */
  uint8_t data = 0;

  Wire.beginTransmission(device_addr);
  Wire.write(reg_addr);             // I am going to read the status of interrup enable 1
  Wire.endTransmission();       // stop condition
  Wire.requestFrom(device_addr, 1);    // start again, request 1 byte from slave
  data = Wire.read();

  return data;
}

// function to set how many samples are averaged in the fifo
// options are 1, 2, 4, 8, 16, and 32
void set_fifo_sample_avg(int samples)
{
  uint8_t fifo_config = 0;
  fifo_config = read_reg(0x57,0x08); // read fifo config register

  // clear bits [7:5] of fifo config reg
  fifo_config &= 0b00011111;
  write_reg(0x57, 0x08, fifo_config);

  // set bits [7:5] in fifo config register (SMP_AVE[2:0])
  fifo_config = read_reg(0x57,0x08);
  switch (samples)
  {
    case 1 : 
      fifo_config |= 0b00000000;
      break;
    case 2 : 
      fifo_config |= 0b00100000;
      break;
    case 4 : 
      fifo_config |= 0b01000000;
      break;
    case 8 : 
      fifo_config |= 0b01100000;
      break;
    case 16 : 
      fifo_config |= 0b10000000;
      break;
    case 32 : 
      fifo_config |= 0b10100000;
      break;
    default:
      fifo_config |= 0b00000000;
      Serial.println("ERROR, SAMPLE AVERAGE IN FIFO CONFIG IS NOT CORRECT");
      Serial.println("Sample Average will default to 1 (no averaging)");
      Serial.println("To change: Please call \"set_fifo_sample_avg()\" with 1, 2, 4, 8, 16 or 32 as the argument");
      break;
  }
  
  write_reg(0x57,0x08,fifo_config); // write back to fifo config address. 
}

// Function to set the full scale range of the ADC. default is 4096. 
void set_ADC_range(int ADC_range)
{
  uint8_t spo2_config = read_reg(0x57,0x0A);  // 0x0A is address of SPO2 config reg

  // clear bits [6:5] of SPO2 config reg
  spo2_config &= 0b10011111;
  write_reg(0x57, 0x0A, spo2_config);

  // set bits [6:5] of SPO2 config reg (SpO2 ADC Range Control)
  spo2_config = read_reg(0x57,0x0A); // read reg again (bits [6:5] have been cleared)
  switch(ADC_range)
  {
    case 2048:
      spo2_config |= 0b00000000;
      break;
    case 4096:
      spo2_config |= 0b00100000;
      break;
    case 8192:
      spo2_config |= 0b01000000;
      break;
    case 16384:
      spo2_config |= 0b01100000;
      break;
    default:
      spo2_config |= 0b00100000;
      Serial.println("ERROR, ADC RANGE IN SPO2 CONFIG IS NOT CORRECT");
      Serial.println("ADC range will default to 4096");
      Serial.println("To change: Please call \"set_ADC_range()\" with 2048, 4096, 8192, or 16384 as the argument");
      break;
  }
  write_reg(0x57, 0x0A, spo2_config);
}

// Function to set the sample rate of the ADC. default is 200 samples per second. 
void set_ADC_sample_rate(int sample_rate)
{
  uint8_t spo2_config = read_reg(0x57,0x0A);  // 0x0A is address of SPO2 config reg

  // clear bits [4:2] of SPO2 config reg
  spo2_config &= 0b11100011;
  write_reg(0x57, 0x0A, spo2_config);

  // set bits [4:2] of SPO2 config reg (SpO2 Sample Rate Control)
  spo2_config = read_reg(0x57,0x0A); // read reg again (bits [4:2] have been cleared)
  switch(sample_rate)
  {
    case 50:
      spo2_config |= 0b00000000;
      break;
    case 100:
      spo2_config |= 0b00000100;
      break;
    case 200:
      spo2_config |= 0b00001000;
      break;
    case 400:
      spo2_config |= 0b00001100;
      break;
    case 800:
      spo2_config |= 0b00010000;
      break;
    case 1000:
      spo2_config |= 0b00010100;
      break;
    case 1600:
      spo2_config |= 0b00011000;
      break;
    case 3200:
      spo2_config |= 0b00011100;
      break;
    default:
      spo2_config |= 0b00001000;
      Serial.println("ERROR, ADC SAMPLE RATE IN SPO2 CONFIG IS NOT CORRECT");
      Serial.println("Sample rate will default to 200 Hz");
      Serial.println("To change: Please call \"set_ADC_sample_rate()\" with 50, 100, 200, 400, 800, 1000, 1600, or 3200 as the argument");
      break;
  }
  write_reg(0x57, 0x0A, spo2_config);
}


// Function to set the LED pulse width in micro seconds (default is max of 411 us)
// as pulse width increases, so does ADC resolution
void set_LED_pulse_width(int pulse_width)
{
  uint8_t spo2_config = read_reg(0x57,0x0A);  // 0x0A is address of SPO2 config reg

  // clear bits [1:0] of SPO2 config reg
  spo2_config &= 0b11111100;
  write_reg(0x57, 0x0A, spo2_config);

  // set bits [1:0] of SPO2 config reg (LED Pulse Width Control and ADC Resolution)
  spo2_config = read_reg(0x57,0x0A); // read reg again (bits [1:0] have been cleared)

  // statment to check if sample rate and pulse width combination is allowed
  // see "Table 11. SpO2 Mode (Allowed Settings)" in the datasheet
  // -- ADD statment

  switch(pulse_width)
  {
    case 69:   // ADC resolution of 15 bits
      spo2_config |= 0b00000000;
      break;
    case 118:  // ADC resolution of 16 bits
      spo2_config |= 0b00000001;
      break;
    case 215:  // ADC resolution of 17 bits
      spo2_config |= 0b00000010;
      break;
    case 411:  // ADC resolution of 18 bits
      spo2_config |= 0b00000011;
      break;
    default:
      spo2_config |= 0b00000011;
      Serial.println("ERROR, LED_PULSE_WIDTH IN SPO2 CONFIG IS NOT CORRECT");
      Serial.println("pulse width will default to 411 us");
      Serial.println("To change: Please call \"set_LED_pulse_width()\" with 69, 118, 215, or 411 as the argument");
      break;
  }
  write_reg(0x57, 0x0A, spo2_config);
}

// function to set the pulse amplitude of the RED LED
void set_red_LED_pulse_amplitude(uint8_t LED_brightness)
{
  uint8_t red_LED_pa = read_reg(0x57, 0x0C);
  red_LED_pa |= LED_brightness;
  write_reg(0x57, 0x0C, red_LED_pa);
}

// function to set the pulse amplitude of the IR LED
void set_ir_LED_pulse_amplitude(uint8_t LED_brightness)
{
  uint8_t ir_LED_pa = read_reg(0x57, 0x0D);
  ir_LED_pa |= LED_brightness;
  write_reg(0x57, 0x0D, ir_LED_pa);
}

// function to set up multi LED mode for SPO2 mode. The red LED will be enabled in slot 1 @ address 0x11
// The IR LED will be enabled in slot 2 @ address 0x11
void set_multi_LED_mode()
{
  uint8_t multi_led_mode = read_reg(0x57, 0x11);
  multi_led_mode |= 0b00100001;  // set slot 2 (bits [6:4]) as 0b010 and set slot 1 (bits [2:0]) as 0b001
  write_reg(0x57, 0x11, multi_led_mode);
}

// sets the mode as SPO2 in the Mode Configuration register (0x09). 
// Both the Red LED and IR led are active in this mode
void set_mode_SPO2()
{
  uint8_t mode_config = read_reg(0x57, 0x09);
  mode_config |= 0b00000011;  // set bits [2:0] as 0b011 for SPO2 mode
  write_reg(0x57, 0x09, mode_config);
}

// function enables fifo rollover
// if data is not read when fifo is full, fifo just rolls back over to zero and overwrites old data
void enable_FIFO_rollover()
{
  uint8_t FIFO_config = read_reg(0x57, 0x08);
  FIFO_config |= 0b00010000;  // set bit 4 high to enable fifo roll over
  write_reg(0x57, 0x08, FIFO_config);
}

// function to reset FIFO
// upon POR the fifo write point contains data 0x08 when it should contain 0x00
void reset_FIFO()
{
  uint8_t fifo_write_pointer = read_reg(0x57, 0x04);
  fifo_write_pointer &= 0b00000000;  // clear all data
  write_reg(0x57, 0x04, fifo_write_pointer);
}

void MAX30102_config(uint8_t LED_brightness, int sample_avg, int sample_rate, int pulse_width, int ADC_range)
{
  set_fifo_sample_avg(sample_avg);

  set_ADC_range(ADC_range);

  set_ADC_sample_rate(sample_rate);

  set_LED_pulse_width(pulse_width);

  set_red_LED_pulse_amplitude(LED_brightness);

  set_ir_LED_pulse_amplitude(LED_brightness);

  set_multi_LED_mode();

  set_mode_SPO2();

  enable_FIFO_rollover();

  reset_FIFO();
}

void loop()
{

}