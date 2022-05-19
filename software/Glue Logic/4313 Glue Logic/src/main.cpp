#include <Arduino.h>
#include <SoftwareSerial.h>

#define RX 8
#define TX 7

SoftwareSerial Serial1(RX, TX);

void setup()
{
  pinMode(PB0, INPUT);
  Serial1.begin(9600);
  Serial1.println("Initializing...");
}

char getValue(int pin) {
  return digitalRead(pin) == HIGH ? 'H':'L';
}

void loop()
{
  Serial1.print("PB0: ");
  Serial1.print(getValue(PB0));
  Serial1.println();
}