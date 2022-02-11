const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const {buffer2bitArray, bitArray2buffer, arrayChunk, padMessage} = require("./helpers/utils");
const assert = chai.assert;

function genSha256Inputs(input, nCount, nWidth = 512, inParam = "in") {
    var segments = arrayChunk(padMessage(buffer2bitArray(Buffer.from(input))), nWidth);
    const tBlock = segments.length / (512 / nWidth);
    
    if(segments.length < nCount) {
        segments = segments.concat(Array(nCount-segments.length).fill(Array(nWidth).fill(0)));
    }
    
    if(segments.length > nCount) {
        throw new Error('Padded message exceeds maximum blocks supported by circuit');
    }
    
    return { segments, "tBlock": tBlock }; 
}


describe("Sha256", function () {
    this.timeout(100000);
    it ("Should parse ToBeSigned", async () => {
        const p = path.join(__dirname, "../", "circuits", "sha256_test.circom")
        const cir = await wasm_tester(p);

        const message = "Jack,Sparrow,1960-04-16"
        const input = genSha256Inputs(message, 1);
        const len = message.length;

        console.log('input.segments',input.segments[0])
        console.log(bitArray2buffer(input.segments[0]).toString('hex'))

        console.log('calculating witness...');

        console.log('tBlock',input.tBlock)

        let inn = buffer2bitArray(Buffer.from(message))
        const add_bits = 512-inn.length
        inn = inn.concat(Array(add_bits).fill(0));
        console.log(inn)

        const witness = await cir.calculateWitness({ "in": inn, len }, true);

        const arrOut = witness.slice(1, 257);
        const hash2 = bitArray2buffer(arrOut).toString("hex");

        assert.equal(hash2,"5fb355822221720ea4ce6734e5a09e459d452574a19310c0cea7c141f43a3dab")
    });
});