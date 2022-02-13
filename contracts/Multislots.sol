// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Multislots {
    function pushSingleValueToSlot(
        uint256 _multislot,
        uint256 _value,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) internal pure returns(uint256 multislot_) {
        require(uint16(_rightOffset) + uint16(_valueBitLength) <= 256, "too many bits");
        require(_value < 1 << _valueBitLength, "too big value");
        uint256 mask = ~((1 << _valueBitLength) - 1 << _rightOffset);
        multislot_ = _multislot & mask;
        multislot_ |= _value << _rightOffset;
    }

    function pushValuesToSlot(
        uint256[2] memory _values,
        uint8[2] memory _bits
    ) internal pure returns(uint256 multislot_) {
        uint16 limit;
        for (uint256 i = 0; i < _bits.length; i++) {
            limit += _bits[i];
            require(limit <= 256, "too many bits");
            require(_values[i] < 1 << _bits[i], "too big value");
            multislot_ |= _values[i];
            if (i + 1 < _bits.length) {
                multislot_ <<= _bits[i + 1];
            }
        }
    }

    function pushValuesToSlot(
        uint256[3] memory _values,
        uint8[3] memory _bits
    ) internal pure returns(uint256 multislot_) {
        uint16 limit;
        for (uint256 i = 0; i < _bits.length; i++) {
            limit += _bits[i];
            require(limit <= 256, "too many bits");
            require(_values[i] < 1 << _bits[i], "too big value");
            multislot_ |= _values[i];
            if (i + 1 < _bits.length) {
                multislot_ <<= _bits[i + 1];
            }
        }
    }

    function pushValuesToSlot(
        uint256[] memory _values,
        uint8[] memory _bits
    ) internal pure returns(uint256 multislot_) {
        require(_values.length == _bits.length, "invalid bits length");
        uint16 limit;
        for (uint256 i = 0; i < _bits.length; i++) {
            limit += _bits[i];
            require(limit <= 256, "too many bits");
            require(_values[i] < 1 << _bits[i], "too big value");
            multislot_ |= _values[i];
            if (i + 1 < _bits.length) {
                multislot_ <<= _bits[i + 1];
            }
        }
    }

    function pullSingleValueFromSlot(
        uint256 _multislot,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) internal pure returns(uint256 value_) {
        require(uint16(_rightOffset) + uint16(_valueBitLength) <= 256, "too many bits");
        uint256 mask = ((1 << _valueBitLength) - 1 << _rightOffset);
        value_ = (_multislot & mask) >> _rightOffset;
    }

    function pullValuesFromSlot(
        uint256 _multislot,
        uint8[2] memory _bits
    ) internal pure returns(uint256[2] memory values_) {
        uint16 limit;
        for (int256 i = int256(_bits.length) - 1; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] = (_multislot << 256 - limit) >> 256 - _bits[uint256(i)];
        }
    }

    function pullValuesFromSlot(
        uint256 _multislot,
        uint8[3] memory _bits
    ) internal pure returns(uint256[3] memory values_) {
        uint16 limit;
        for (int256 i = int256(_bits.length) - 1; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] = (_multislot << 256 - limit) >> 256 - _bits[uint256(i)];
        }
    }

    function pullValuesFromSlot(
        uint256 _multislot,
        uint8[] memory _bits
    ) internal pure returns(uint256[] memory values_) {
        require(_bits.length > 0, "too few bits");
        values_ = new uint256[](_bits.length);
        uint16 limit;
        for (int256 i = int256(_bits.length) - 1; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] = (_multislot << 256 - limit) >> 256 - _bits[uint256(i)];
        }
    }
}