# Multislots Library

## Introduction

The Multislots library is a powerful tool for optimizing storage space and reducing gas costs in Ethereum smart contracts. It provides two key contracts: Multislot and AdjacentMultislots. Let me walk you through the features and usage of these contracts.

## Multislot Contract

The Multislot contract allows you to efficiently pack multiple values into a single 256-bit multislot. This is particularly valuable when dealing with different data types and bit layouts. You can create type-independent structs and read any storage slot with a custom bit-layout. For example, you can store values as uint32, uint96, uint32, and uint96, but read them as uint128 and uint128. 

Here's an example visual representation of how the Multislot contract packs data:

| uint256 | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit | 32 bit |
|---------|--------|--------|--------|--------|--------|--------|--------|--------|
| uint96  | 32 bit | 32 bit | 32 bit |        |        |        |        |        |
| uint32  | 32 bit |        |        |        |        |        |        |        |

| uint256 | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     | 32 bit     |
|---------|------------|------------|------------|------------|------------|------------|------------|------------|
|| uint96 - 1/3 | uint96 - 2/3 | uint96 - 3/3 | uint32 - 1/1 | uint96 - 1/3 | uint96 - 2/3 | uint96 - 3/3 | uint32 - 1/1 |

## AdjacentMultislots Contract

The AdjacentMultislots contract is designed to optimize storage space when dealing with large datasets, such as whitelists. Rather than resorting to conventional methods such as Merkle Trees or individual address storage, this contract packs elements closely together, utilizing every available bit.

For example, if you need to store 80 addresses in a whitelist, it's challenging to optimize gas costs. The AdjacentMultislots contract addresses this by packing data tightly, saving substantial gas costs during initialization. However, it's important to note that storage updates can be more expensive, as updates affect multiple slots.

Here's an illustration of how adjacent multislots work:

| Slot 1 | 160 bit | 96 bit  | Slot 2 | 64 bits | 160 bits | 32 bit |
|--------|---------|---------|--------|---------|---------|--------|
|        | I am whole address A | I am only the first 96 bits of address B | | I am the second part of address B | I am the whole address C | I am not used |

Updating address B alone will incur additional gas costs, so it's best suited for storing immutable-like data.

> Note: Updating address A and C together or all addresses in a single transaction does not incur the extra gas cost.

## Getting Started

Here are some useful commands to get started with this project after cloning the repository:

### Install Dependencies
```sh
pnpm i
```

### Compile Contracts
```sh
pnpm compile
```

### Run Tests
```sh
pnpm test
```

Make sure to create a `.env` file and populate it with information from `.env.example`. Ensure that your `.env` file contains the setting `REPORT_GAS=true` to see gas reports from tests.

## License

This project is licensed under the MIT License.

For more details, refer to the [LICENSE](LICENSE) file.

For additional information, check out the following resources:
- [MerkleTree](https://en.wikipedia.org/wiki/Merkle_tree)
- [EVM Storage Layout](https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html)
- [EVM 256 Stack](https://ethereum.org/en/developers/docs/evm/#:~:text=each%20item%20is%20a%20256-bit%20word%2C%20which%20was%20chosen%20for%20the%20ease%20of%20use%20with%20256-bit%20cryptography%20(such%20as%20keccak-256%20hashes%20or%20secp256k1%20signatures).)
- [EVM Gas Costs (SSTORE)](https://github.com/wolflo/evm-opcodes/blob/main/gas.md#a7-sstore)
