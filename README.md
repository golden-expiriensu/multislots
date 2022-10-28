# Multislots
## _Library for using all available bits in slots_

## Multislot contract

Allows you to pack multiple values to one 256-bit multislot. So if you have uint32, uint96, uint32 and uint96 you can pack them to one slot. Basically this library is just dynamic solidity struct. It have little utility by itself, but allows you to create type-independent structs and read any storage slot by any bit-layout. For example if you want to store values as uint32, uint96, uint32 and uint96, but read as uint128 and uint128 you good to go.

| uint256 | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit |
|---------|--------|--------|--------|--------|--------|--------|--------|--------|
| uint96  | 32 bit | 32 bit | 32 bit |        |        |        |        |        |
| uint32  | 32 bit |        |        |        |        |        |        |        |

| uint256 | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     |
|---------|------------|------------|------------|------------|------------|------------|------------|------------|
|| uint96 - 1/3 | uint96 - 2/3 | uint96 - 3/3 | uint32 - 1/1 | uint96 - 1/3 | uint96 - 2/3 | uint96 - 3/3 | uint32 - 1/1 |

## AdjacentMultislots contract

This is there optimization takes it's place. Let's imagine you need to store 80 addresses as a whitelist. First and right idea that comes to mind is to use [MerkleTree][MerkleTree]. Everything seems good and you return to the your customer and say that you need a little backend code to provide log2(n) array of hashes to frontend. Backend? We will not have backend, store everything in SC. 80 addresses is 80 storage slots it is ~1.760.000 gas for initialization [EVM will pack you array data if it is possible, but address(uint160) cannot be packed with another address to one slot][EVMLayout]. Is there any options to optimize it? It is. [In not 256-stack machine][EVM256Stack] 160 * 80 bits information will occupy 12800 bits and it is 50 slots ~1.100.000 gas - 660.000 gas difference! But solidity has no build-in tools to implement it (maybe it makes sense to use abi encode or encode packed and create some lib on top of that, but I believe that AdjacentMultislots lib looks better). So how do adjacent multislots work? Actually it is very simple to undersand in context non-256-stack, you just pack data as tight as it possible, so for our addresses you pack 160-bit array like this: 160 bit -> 320 bit -> 480 bit -> etc. The only drawback of it is storage updating, let me explain. EVM writes/reads only 256-bit slot at time, and write/read gas cost is being calculated in according to 256-bit slots. But if you will place 3 addresses into 2 slots you will have following layout:

| Slot 1 | 160 bit | 96 bit  | Slot 2 | 64 bits | 160 bits | 32 bit |
|-|-|-|-|-|-|-|
| | I am whole address A | I am only first 96 bits of address B | | I am the second part of address B | I am whole address C | I am so useless |
Take a look at address B - it is stored at two slots. We will save gas for the first write (since we occupy not 3 but 2 slots), but if you will update address B you will update 2 slots and pay for 2 slots update. [Second write is cheaper than first one][SStore], but if you have to update it often you will waste more gas, so it is only makes sence for storing immutable-like data.
> If you will update only address A and C you will not waste x2 gas. If you will update A, B and C at the same transaction you will not waste x2 gas as well. The only drawback is updating address B alone.

## Useful commands after git clone

Install dependencies
```sh
pnpm i
```

Compile contracts
```sh
pnpm compile
```

Run tests
```sh
pnpm test
```

> Create .env file and fill it with information from .env.example. You should have .env file with "REPORT_GAS=true" in it to see gas report from tests.

## License

MIT

   [MerkleTree]: <https://en.wikipedia.org/wiki/Merkle_tree>
   [EVMLayout]: <https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html>
   [EVM256Stack]: <https://ethereum.org/en/developers/docs/evm/#:~:text=each%20item%20is%20a%20256-bit%20word%2C%20which%20was%20chosen%20for%20the%20ease%20of%20use%20with%20256-bit%20cryptography%20(such%20as%20keccak-256%20hashes%20or%20secp256k1%20signatures).>
   [SStore]: <https://github.com/wolflo/evm-opcodes/blob/main/gas.md#a7-sstore>
