// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Multislot.sol";

contract TestContract {
    using Multislot for uint256;
    using Multislot for uint256[];

    uint256 multislot;

    function setValueToSlot(
        uint256 _value,
        uint256 _rightOffset,
        uint256 _valueBitLength
    ) external {
        multislot = multislot.insertValue(
            _value,
            _rightOffset,
            _valueBitLength
        );
    }

    function setValuesToSlot(uint256[] calldata _values, uint256[] calldata _bits)
        external
    {
        multislot = _values.packValues(_bits);
    }

    function getValueFromSlot(uint256 _rightOffset, uint256 _valueBitLength)
        external
        view
        returns (uint256 _value)
    {
        _value = multislot.extractSingleValue(_rightOffset, _valueBitLength);
    }

    function getValuesFromSlot(uint256[] calldata _bits)
        external
        view
        returns (uint256[] memory values_)
    {
        values_ = multislot.unpackValues(_bits);
    }
}
