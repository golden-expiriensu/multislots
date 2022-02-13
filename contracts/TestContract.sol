pragma solidity ^0.8.4;

import "./Multislots.sol";

contract TestContract {
    using Multislots for uint256;
    using Multislots for uint256[2];
    using Multislots for uint256[3];
    using Multislots for uint256[];

    uint256 multislot;

    function setValueToSlot(
        uint256 _value,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) external {
        multislot = multislot.pushSingleValueToSlot(_value, _rightOffset, _valueBitLength);
    }

    function setValuesToSlot(
        uint256[] calldata _values,
        uint8[] calldata _bits
    ) external {
        multislot = _values.pushValuesToSlot(_bits);
    }

    function getValueFromSlot(
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) external view returns(uint256 _value) {
        _value = multislot.pullSingleValueFromSlot(_rightOffset, _valueBitLength);
    }

    function getValuesFromSlot(
        uint8[] calldata _bits
    ) external view returns(uint256[] memory values_) {
        values_ = multislot.pullValuesFromSlot(_bits);
    }
}