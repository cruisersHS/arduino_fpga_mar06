#include <stdio.h>

int write1 = 7;
int write2 = 8;
int write3 = 9;
int write4 = 10;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); // start serial connection to print out debug messages and data
  pinMode(write1, OUTPUT);
  pinMode(write2, OUTPUT);
  pinMode(write3, OUTPUT);
  pinMode(write4, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  //delay(100);
  digitalWrite(write4, LOW);
  digitalWrite(write1, HIGH);
  Serial.println("Writing LED 1......");
  delay(1000);
  digitalWrite(write1, LOW);
  digitalWrite(write2, HIGH);
  Serial.println("Writing LED 2......");
  delay(1000);
  digitalWrite(write2, LOW);
  digitalWrite(write3, HIGH);
  Serial.println("Writing LED 3......");
  delay(1000);
  digitalWrite(write3, LOW);
  digitalWrite(write4, HIGH);
  Serial.println("Writing LED 4......");
  delay(1000);
}
