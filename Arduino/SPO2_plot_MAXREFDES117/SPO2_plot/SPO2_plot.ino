/*
Confuigures the MAX30102 on the MAXREFDES117 eval board for SPO2 mode
Samples at 25 Hz and plots graph using serial plotter
*/

#include <Wire.h>

void setup()
{
  Wire.begin();        // start I2C bus
  Serial.begin(9600);  // start the Serial interface
  Serial.println("I2C and serial interfaces are up!");

  // disable interrupts
  /*
    - for a write, first comes slave ID, then register address, then data
  */
  Wire.beginTransmission(0x57); // hex value of 0x57 is default MAX30102 address
  Wire.write(0x02);             // Interrupt enable 1 address
  Wire.write(0b01000000);       // disable all interrupts except power ready (B6)
  Wire.endTransmission();

  // read status of interrupts
  /*
    - for a read, first comes slave ID, then register address
    - next, a stop condition occurs
    - finally, a new transmission is started and the slave ID goes first. The data follows and can be read
  */
  Wire.beginTransmission(0x57);
  Wire.write(0x00);             // I am going to read the status of interrup enable 1
  Wire.endTransmission();       // stop condition
  Wire.requestFrom(0x57, 1);    // start again, request 1 byte from slave
  char intrp_status = Wire.read();

  // print interrupt status in binary
  Serial.print("Interrupt 1 status is ");
  for (int i = 7; i >= 0; i--) {
      Serial.print(bitRead(intrp_status, i));
    }
    Serial.println();
  
}

void loop()
{

}