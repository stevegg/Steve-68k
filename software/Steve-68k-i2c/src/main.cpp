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

#define SIGNAL_PORT     PORTC
#define I2C_SEL_PIN     21
#define I2CENABLE_PIN   PINC5
#define DTACK_PIN       PINC6
#define RW_PIN          PINC2

#define DATA_PORT       PORTB
#define DATA_PIN        PINB
#define ADDRESS_PORT    PORTA
#define ADDRESS_PIN     PINA

// Called whenever the I2C_SEL pin goes LOW
void processBusInterruptHandler() {
  processBus = true;
}

void setup() {

  Serial.begin(9600);

  // Setup Address Port as INPUT
  DDRA = 0x00;
  // Setup Data Port initially as INPUT
  DDRB = 0x00;

  // DTACK_PIN is an OUTPUT
  DDRC |= (1<<DTACK_PIN);
  // Set it's state to HI
  SIGNAL_PORT |= (1<<DTACK_PIN);

  // I2CENABLE is an INPUT
  DDRC &= ~(1<<I2CENABLE_PIN);

  matrix.begin(0x70);
  // Show Rdy on Display
  matrix.print("Rdy");
  matrix.writeDisplay();

  // Setup an interrupt on the falling edge of I2CENABLE pin
  attachInterrupt(digitalPinToInterrupt(I2C_SEL_PIN), processBusInterruptHandler, FALLING);

  Serial.println("Initialization complete.");
}

void loop() {

  if ( processBus ) {
    // Check RW
    bool reading = (SIGNAL_PORT & (1<<RW_PIN)) == 1;
    char buffer[128];
    // Get the address
    byte address = ADDRESS_PIN;
    byte data = DATA_PIN;

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
    SIGNAL_PORT &= ~(1<<DTACK_PIN);
    delayMicroseconds(10);
    SIGNAL_PORT |= (1<<DTACK_PIN);
  }
}