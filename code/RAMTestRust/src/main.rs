#![no_std]

// use core::ptr;
use core::panic::PanicInfo;

// memory map
// const ROMBASE:  *mut u32 = 0x000000 as *mut u32;         // Base address for ROM space
const RAMBASE:  *mut u32 = 0xE00000 as *mut u32;         // Base address for RAM
// const RAMLIMIT: *mut u32 = 0xE0FFFF as *mut u32;         // Limit of onboard RAM
const ERRIND:   *mut u32 = 0xF00000 as *mut u32;
const TESTLIMIT:*mut u32 = 0xE00F00 as *mut u32;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

fn main() {}

// fn main() {

//     loop {
//         let mut ram_ptr: *mut u32 = RAMBASE;
//         loop {
//             unsafe {
//                 ptr::write(ram_ptr, 0x00);
//                 let n = ptr::read(ram_ptr);
//                 ram_ptr = ram_ptr.add(1);
//                 if n != 0x00 {
//                     ptr::write(ERRIND, n);
//                 }
//             }

//             if ram_ptr == TESTLIMIT {
//                 break;
//             }

//         }
//     }
// }
