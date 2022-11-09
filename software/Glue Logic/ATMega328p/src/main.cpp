#include <Arduino.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>

#define SERIAL_OUTPUT 1

typedef unsigned char byte;
void clockCycle();

LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display
//                      D0    ................    D7
const int DataBus[] = { 8, 9, 10, 11, 12, 13, 7, 6 };
//                         A0 ...... A4
const int AddressBus[] = { 3, 4, 16, 17};
// Signal lines
const int CLK = 2;
const int CE = 14;
const int RW = 15;

void setup() {
  // Set the DataBus as INPUT/OUTPUT
  for ( short i = 0; i < 8; i++ ) {
    pinMode(DataBus[i], INPUT);
  }
  for ( short i = 0; i < 4; i ++ ) {
    pinMode(AddressBus[i], INPUT);
  }

  // All other pins as input
  pinMode(CE, INPUT);
  pinMode(RW, INPUT);

  lcd.init();
  lcd.backlight();
  lcd.clear();
  attachInterrupt(digitalPinToInterrupt(CLK), clockCycle, RISING);
}

// Convert databus to a byte
byte readBus(const int bus[], int len) {
  byte busValue = 0;
  for ( short i = 0; i < len; i ++ ) {
    busValue |= digitalRead(bus[i]) << i;
  }
  return busValue;
}

// Write a byte to the databus
void writeDataBus(byte value, int bus[], int len) {
  for (short i = 0; i < len; i ++ ) {
    pinMode(bus[i], OUTPUT);
    digitalWrite(bus[i], (value & (1 << i)) != 0 ? HIGH : LOW );
  }
}

char *byteToBinary(char *buffer, int len, byte value, short bits) {
  // Fill buffer with 0s first
  memset(buffer, 0, len);
  for ( int i = 0; i < bits; i ++ ) {
    buffer[(bits-1)-i] = ((value & (1 << i)) != 0) ? '1' : '0';
  }
  return buffer;
}

void writeTo(byte address, byte data) {
  char dataBuffer[80];
  char addressBusBuffer[5];
  char dataBusBuffer[9];
  byteToBinary(addressBusBuffer, sizeof(addressBusBuffer), address, 4);
  byteToBinary(dataBusBuffer, sizeof(dataBusBuffer), data, 8);
  memset(dataBuffer, 0, sizeof(dataBuffer));
  sprintf(dataBuffer, "WRITE  : %s:%02X - %s:%02X %c", addressBusBuffer, address, dataBusBuffer, data, char(data));
  Serial.println(dataBuffer);
}

void readFrom(byte address, byte data) {
  char dataBuffer[80];
  char addressBusBuffer[5];
  char dataBusBuffer[9];
  byteToBinary(addressBusBuffer, sizeof(addressBusBuffer), address, 4);
  byteToBinary(dataBusBuffer, sizeof(dataBusBuffer), data, 8);
  memset(dataBuffer, 0, sizeof(dataBuffer));
  sprintf(dataBuffer, "READ   : %s:%02X - %s:%02X %c", addressBusBuffer, address, dataBusBuffer, data, char(data));
  Serial.println(dataBuffer);
}

void loop() {

}

// Interrupt method triggered on the rising edge of the clock
void clockCycle() {
  
  // Read current bus and signal values
  byte dataBusValue = readBus(DataBus, 8);
  byte addressBusValue = readBus(AddressBus, 4);
  bool chipSelect = digitalRead(CE) == LOW;
  bool read = digitalRead(RW) == HIGH;

  // Is the data for us?  It is if CE is LOW
  if (chipSelect) {
    // Write to the lcd
    lcd.write(dataBusValue);
    // // Are we being read from or written to
    // if (read) {
    //   readFrom( addressBusValue, dataBusValue );
    // } else {
    //   // We're being written to
    //   writeTo( addressBusValue, dataBusValue );
    // }
  }
}