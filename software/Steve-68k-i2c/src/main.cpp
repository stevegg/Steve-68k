#include <Arduino.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

/**
 * Fuse settings for ATMega 1284 for 16mhz external oscillator
 * Low Byte: 0xFF (blank all)
 * High Byte: 0xDE (Check SPIEN and BOOTRST)
 * Extended: 0xFD (Check BODLEVEL1)
 * 
 * Port Manipulation
 *    DDR 1 = OUTPUT, 0 = INPUT
 *    Use PIN to read
 *    Use PORT to write
 * 
 */

Adafruit_7segment matrix = Adafruit_7segment();

volatile boolean processBus = false;

#define I2C_SEL_PIN   2
#define I2C_DTACK     PINC6
#define RW_PIN        PIND2

#define DATA_PORT     PORTA
#define ADDRESS_LOW   PORTC

// Called whenever the I2C_SEL pin goes LOW
void processBusInterruptHandler() {

  processBus = true;

}

void setup() {

  Serial.begin(9600);

  // Setup Data Port initially as INPUT
  DDRA = 0x00;
  // Setup Address Low as INPUT
  DDRC &= ~((1<<PINC2) | (1<<PINC3) | (1<<PINC4) | (1<<PINC5));

  // I2C_DTACK is an OUTPUT
  DDRC |= (1<<I2C_DTACK);
  // Set it's state to HI
  PORTC |= (1<<I2C_DTACK);

  // I2C_SEL is an INPUT
  pinMode(I2C_SEL_PIN, INPUT);

  // Setup an interrupt on the I2C_SEL pin

  matrix.begin(0x70);
  // Show Rdy on Display
  matrix.print("Rdy");
  matrix.writeDisplay();

  attachInterrupt(digitalPinToInterrupt(I2C_SEL_PIN), processBusInterruptHandler, FALLING);

  Serial.println("Initialization complete.");
}

void loop() {

  if ( processBus ) {
    // Check RW
    bool reading = (PIND & (1<<RW_PIN)) == 1;
    char buffer[128];
    // Get the address
    byte address = ADDRESS_LOW & ((1<<PINC2)|(1<<PINC3)|(1<<PINC4)|(1<<PINC5));
    byte data = PINA;

    sprintf(buffer, "SEL: %c %02X : %02X", (reading)?'R':'W', address, data);
    Serial.println(buffer);

    if ( !reading ) {
      if ( address == 0x00 ) {
        // Write data to the 7 segment LED
        matrix.print(data, HEX);
        matrix.writeDisplay();
      } else if ( address == 0x01) {
        // Write data to the Serial port
        Serial.write(data);
      }
    }

    delay(1000);

    processBus = false;    
    // Now assert I2C_DTACK
    PORTC &= ~(1<<I2C_DTACK);
    delayMicroseconds(10);
    PORTC |= (1<<I2C_DTACK);


  }
}