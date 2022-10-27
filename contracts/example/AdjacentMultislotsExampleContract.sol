// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../AdjacentMultislots.sol";

contract AdjacentMultislotsExampleContract {
    // This struct cannot occupy less that 8 slots because address(uint160) can only be packed with {uint8, ..., uint96}
    // But with AdjacentMultislots it can be packed to 160 * 8 = 1280 bits, 1280 / 256 = 5 slots
    //
    // Beware that if you will update b, d, e, g you will pay x2 gas because those values will be
    // stored in 2 slots: in the end of the y slot and at the start of the y + 1 slot
    // => It is useless for frequently updating data
    //
    // Or if understand things under the hood, you can set to b, d, e, g variables, that unlikely to be changed,
    // and to a, c, f, h variables, that will be updated very often
    //
    // P.S. In DAPPs without backend merkle tree is not an option because then every address update will cause frontend redeployment
    struct WhitelistWithoutMerkleTree {
        address a;
        address b;
        address c;
        address d;
        address e;
        address f;
        address g;
        address h;
    }

    // 0-7 slots for the defaultStruct whitelist
    WhitelistWithoutMerkleTree defaultStruct;

    // 0xe6b...d5c - 0xe6b...d60 slots for the packed whitelist
    uint256 constant whitelistSlot = 8;

    event GasLog(uint256 gasSpent);

    function setUnoptimized(WhitelistWithoutMerkleTree calldata _data)
        external
    {
        uint256 gasBefore = gasleft();

        defaultStruct = _data;

        uint256 gasAfter = gasleft();

        emit GasLog(gasBefore - gasAfter);
    }

    function setOptimized(WhitelistWithoutMerkleTree calldata _data) external {
        uint256 gasBefore = gasleft();

        AdjacentMultislots.write(
            whitelistSlot,
            toDynamic8Array(
                [
                    _data.a,
                    _data.b,
                    _data.c,
                    _data.d,
                    _data.e,
                    _data.f,
                    _data.g,
                    _data.h
                ]
            ),
            toDynamic8Array([160, 160, 160, 160, 160, 160, 160, 160])
        );

        uint256 gasAfter = gasleft();

        emit GasLog(gasBefore - gasAfter);
    }

    function getUnoptimized()
        external
        view
        returns (WhitelistWithoutMerkleTree memory)
    {
        return defaultStruct;
    }

    function getOptimized()
        external
        view
        returns (WhitelistWithoutMerkleTree memory)
    {
        uint256[] memory values = AdjacentMultislots.read(
            whitelistSlot,
            toDynamic8Array([160, 160, 160, 160, 160, 160, 160, 160])
        );

        return
            WhitelistWithoutMerkleTree({
                a: address(uint160(values[0])),
                b: address(uint160(values[1])),
                c: address(uint160(values[2])),
                d: address(uint160(values[3])),
                e: address(uint160(values[4])),
                f: address(uint160(values[5])),
                g: address(uint160(values[6])),
                h: address(uint160(values[7]))
            });
    }

    function toDynamic8Array(address[8] memory _data)
        private
        pure
        returns (uint256[] memory result_)
    {
        result_ = new uint256[](8);

        for (uint256 i; i < 8; i++) result_[i] = uint160(_data[i]);
    }

    function toDynamic8Array(uint8[8] memory _data)
        private
        pure
        returns (uint256[] memory result_)
    {
        result_ = new uint256[](8);

        for (uint256 i; i < 8; i++) result_[i] = _data[i];
    }
}
