#include <Wire.h>
#include <stdint.h>
#include <inttypes.h>

int address;
int high_byte_pin = 2;    //IO2
int high_byte_pin2 = 3;    //IO3
uint32_t v = 0x3C4D5E6F;
byte v_arr[4];
 
void setup()
{
  v_arr[0] = v&0xFF;            // LSB
  v_arr[1] = (v>>8)&0xFF;       //
  v_arr[2] = (v>>16)&0xFF;      //  
  v_arr[3] = (v>>24)&0xFF;      //  MSB
  
  address = 114;
  pinMode(high_byte_pin, OUTPUT);
  pinMode(high_byte_pin2, OUTPUT);
  Wire.begin();
  Serial.begin(9600);
  Serial.println("Verilog I2C Test\n\n");

  delay(1000);
}

void loop()
{
  Serial.print("Address\t");
  Serial.println(address);
  //Serial.print("Value\t");
  //Serial.println(value);
  int error;
  //digitalWrite(high_byte_pin, LOW);
  //digitalWrite(high_byte_pin2, LOW);
  
  for(int i = 0; i < 4; i++) {
      if(i == 3) digitalWrite(high_byte_pin, HIGH);
      else digitalWrite(high_byte_pin, LOW);
      Wire.beginTransmission(address);
      Wire.write(v_arr[i]);
      error = Wire.endTransmission();
      
      //delay(1000);
    } 
  //Wire.requestFrom(address, 2);
  //address: the 7-bit address of the device to request bytes from
  //quantity: the number of bytes to request
  delay(1000);
  Serial.println("\n");
   
}
