//              0,  1,  2, 3, 4,  5,  6,  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
pinAddress = [ -1, -1, -1, 0, 1, -1, 11, 10, 4, 5,  6,  7,  8,  9, -1, -1,  2,  3]
//             A0 A1 A2  A3
AddressBus = [ 17, 16, 4, 3 ];
DataBus = [ 6, 7, 13, 12, 11, 10,  9, 8 ];

//              AAAADDDDDDDD
//              321076543210
addressValue = "000100000001";

const HIGH = 1;
const LOW = 0;

function digitalRead(pin) {
    var index = pinAddress[pin];
    var bit = addressValue[index];
    var result = ( bit === "1") ? HIGH : LOW;
    // console.log("Digital Pin : " + pin + ", Index : " + index+ ", Value: " + bit + ", " + result);
    return result;
}

// Address Bus
function readBus(bus, len) {
    var busValue = 0;
    for ( var i = 0; i < len; i ++ ) {
        busValue |= digitalRead(bus[i]) << i;
    }
    return busValue;
}

// for ( var i = 0; i < pinAddress.length; i ++ ) {
//     var value = '-';
//     if ( pinAddress[i] != -1 ) {
//         value = addressValue[pinAddress[i]];
//     }
//     console.log('Pin ' + i + ' : ', value);
// }

console.log("Address : " + readBus(AddressBus, 4));
console.log("Data : " + readBus(DataBus, 8));
