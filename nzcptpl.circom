pragma circom 2.0.0;

include "./circomlib-master/circuits/sha256/sha256.circom";


/* CBOR types */
#define MAJOR_TYPE_INT 0
#define MAJOR_TYPE_NEGATIVE_INT 1
#define MAJOR_TYPE_BYTES 2
#define MAJOR_TYPE_STRING 3
#define MAJOR_TYPE_ARRAY 4
#define MAJOR_TYPE_MAP 5
#define MAJOR_TYPE_TAG 6
#define MAJOR_TYPE_CONTENT_FREE 7

#define CREDENTIAL_SUBJECT_PATH_LEN 2

#define readType(v,type,buffer,pos) \
    var v = buffer[pos]; \
    var type = v >> 5; \
    pos++;


template NZCP() {





    var ToBeSignedBits = 2512;
    var ToBeSignedBytes = ToBeSignedBits/8;

    signal input a[ToBeSignedBits];
    signal output c[256];
    signal output d;

    var k;

    // component sha256 = Sha256(ToBeSignedBits);

    // for (k=0; k<ToBeSignedBits; k++) {
    //     sha256.in[k] <== a[k];
    // }

    // for (k=0; k<256; k++) {
    //     c[k] <== sha256.out[k];
    // }


    // convert bits to bytes
    signal ToBeSigned[ToBeSignedBytes];
    for (k=0; k<ToBeSignedBytes; k++) {
        var lc1=0;

        var e2 = 1;
        for (var i = 7; i>=0; i--) {
            lc1 += a[k*8+i] * e2;
            e2 = e2 + e2;
        }

        lc1 ==> ToBeSigned[k];
    }

    signal v;
    v <== 168;

    // TODO: are we sure that type,three_upper_bits,upper_bit_1,upper_bit_2,upper_bit_3 are 8 bits?
    signal type;

    // assign `type` signal
    // shift 0bXXXYYYYY to 0b00000XXX
    // v is a trusted signal
    type <-- v >> 5;

    signal low_v;
    low_v <== v & 0x1F;
    type*32 + low_v === v;



    // TODO: read type as signal (type, pos)

    d <== ToBeSigned[0];

}

component main = NZCP();

