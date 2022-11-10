#define RAMBASE     0xE00000    // Base address for RAM
#define RAMLIMIT    0xE0FFFF    // Limit of onboard RAM
#define ROMBASE     0x000000    // Base address for ROM space
#define ERRIND      0xF00000
#define TESTLIMIT   0xE00F00

int main() {
    asm("move.l #0xE0FFFF,%sp"); // Set up initial stack pointer
    while ( 1 ) {
        for ( char *ramPtr = (char *)RAMBASE; ramPtr < (char *)TESTLIMIT; ramPtr ++ ) {
            *ramPtr = 0x00;
            if ( *ramPtr != 0x00 ) {
                *((char *)ERRIND) = 0xFF;
            }
        }
    }
}