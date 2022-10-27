// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../AdjacentMultislots.sol";

contract AdjacentMultislotsExampleContract {
    // This struct cannot occupy less that 3 slots - 60000 gas for the first write
    // because address(uint160) can only be packed with {uint8, ..., uint96}.
    // But with AdjacentMultislots it can be packed to 160 * 3 = 480 bits, 480 / 256 = 1.875 ~ 2 slots
    // Beware that if you will update address b, you will pay for updating 2 slots
    // so it is mostly useful for one-time storage write
    // Or if understand things under the hood, you can set to address b variable, that unlikely to be changed,
    // and to a and c variables, that will be updated quite often
    struct StructThatCannotBeOptimized {
        address a;
        address b;
        address c;
    }

    // 0, 1, 2 slot for the unoptimized struct
    StructThatCannotBeOptimized public unoptimized;
    // 3, 4 slot for the optimized struct
    uint256 optimizedStructMultislot1;
    uint256 optimizedStructMultislot2;

    event GasLog(uint256 gasSpent);

    function setUnoptimized(StructThatCannotBeOptimized calldata _data)
        external
    {
        uint256 gasBefore = gasleft();

        unoptimized = _data;

        uint256 gasAfter = gasleft();

        emit GasLog(gasBefore - gasAfter);
    }

    function setOptimized(StructThatCannotBeOptimized calldata _data) external {
        uint256 writeAt;

        uint256 gasBefore = gasleft();

        assembly {
            writeAt := optimizedStructMultislot1.slot
        }

        AdjacentMultislots.writeValues(
            writeAt,
            toDynamic3Array([_data.a, _data.b, _data.c]),
            toDynamic3Array([160, 160, 160])
        );

        uint256 gasAfter = gasleft();

        emit GasLog(gasBefore - gasAfter);
    }

    function getOptimized()
        external
        view
        returns (StructThatCannotBeOptimized memory result_)
    {
        uint256 slot1;
        uint256 slot2;

        assembly {
            slot1 := sload(3)
            slot2 := sload(4)
        }

        result_.a = address(uint160(slot1 >> 96));
        result_.c = address(uint160((slot2 << 64) >> 96));
        result_.b = address(
            uint160(((slot1 - ((slot1 >> 96) << 96)) << 64) | (slot2 >> 192))
        );
    }

    function toDynamic3Array(address[3] memory _data)
        private
        pure
        returns (uint256[] memory result_)
    {
        result_ = new uint256[](3);

        result_[0] = uint160(_data[0]);
        result_[1] = uint160(_data[1]);
        result_[2] = uint160(_data[2]);
    }

    function toDynamic3Array(uint8[3] memory _data)
        private
        pure
        returns (uint256[] memory result_)
    {
        result_ = new uint256[](3);

        result_[0] = _data[0];
        result_[1] = _data[1];
        result_[2] = _data[2];
    }
}
