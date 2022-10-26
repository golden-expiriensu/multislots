# Multislots library

A library for use in solidity smart contracts, which allows you to contain multiple values in one 256-bit slot.
Storing values in a single slot much cheaper than pack that values into struct like:
struct S {
    uint32 value32;
    uint216 value216;
    uint8 value8;
}, because you also waste gas on packing and unpacking the struct.
For cheap chains like bsc and fantom, there is no need to use it, but if you use an array of these slots on the mainnet, you can save gas for those operations.

Check TestContract.sol and Multislots.test.ts for an example of library use
