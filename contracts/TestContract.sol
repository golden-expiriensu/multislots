// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Multislot.sol";

contract TestContract {
    using Multislot for uint256;
    using Multislot for uint256[];

    uint256 multislot;

    function setValueToSlot(
        uint256 _value,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) external {
        multislot = multislot.insertValueToSlot(
            _value,
            _rightOffset,
            _valueBitLength
        );
    }

    function setValuesToSlot(uint256[] calldata _values, uint8[] calldata _bits)
        external
    {
        multislot = _values.packValuesToSlot(_bits);
    }

    function getValueFromSlot(uint8 _rightOffset, uint8 _valueBitLength)
        external
        view
        returns (uint256 _value)
    {
        _value = multislot.extractSingleValueFromSlot(
            _rightOffset,
            _valueBitLength
        );
    }

    function getValuesFromSlot(uint8[] calldata _bits)
        external
        view
        returns (uint256[] memory values_)
    {
        values_ = multislot.unpackValuesFromSlot(_bits);
    }
}
