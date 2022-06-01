#include <Arduino.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display

int LED = 10;

void setup() {
  pinMode(LED, OUTPUT);
  lcd.init();                      // initialize the lcd 
  lcd.backlight();
  Serial.begin(9600);
  Serial.println("Enter some characters: ");
  lcd.print("Waiting...");
}

void loop() {
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  delay(1000);
  // when characters arrive over the serial port...
  if (Serial.available()) {
    // wait a bit for the entire message to arrive
    delay(100);
    // clear the screen
    lcd.clear();
    // read all the available characters
    while (Serial.available() > 0) {
      // display each character to the LCD
      char c = Serial.read();
      Serial.write(c);
      lcd.print(c);
    }
  }
}

