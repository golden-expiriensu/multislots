// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title A library that facilitates the use of multislots
/// @notice You have to only specify the values and how many bits they should take in 256-bit slot
/// @dev There is several functions for single value, [2], [3] and [] values for concise using in the code
/// @dev You always can delete these functions or add your own for [special value]
library Multislots {
    /// @notice Pushs single value with specified bit-length and right offset to an existing multislot
    /// @dev Assembly advantage: 211 / 211 (via Multislots.test.ts)
    /// @param _multislot An existing multislot in which you want to push the value
    /// @param _value The value to push
    /// @param _rightOffset An bit-offset from the right side of the _value: 0x|left offset|value|right offset|
    /// @param _valueBitLength How many bits value occupy in the _multislot
    /// @return multislot_ The result of _multislot with new value
    function pushSingleValueToSlot(
        uint256 _multislot,
        uint256 _value,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) internal pure returns(uint256 multislot_) {
        assembly {
            if gt(add(_rightOffset, _valueBitLength), 256) {
                revert(0, 0)
            }
            let max := shl(_valueBitLength, 1)
            if or(gt(_value, max), eq(_value, max)) {
                revert(0, 0)
            }

            let mask := not(shl(_rightOffset, sub(max, 1)))
            multislot_ := and(_multislot, mask)
            multislot_ := or(multislot_, shl(_rightOffset, _value))
        }
    }

    /// @notice An analog of pushValuesToSlot with arrays with const (2) length as arguments
    function pushValuesToSlot(
        uint256[2] memory _values,
        uint8[2] memory _bits
    ) internal pure returns(uint256 multislot_) {
        uint16 limit;
        for (uint256 i; i < 2; i++) {
            limit += _bits[i];
            require(limit <= 256, "too many bits");
            require(_values[i] < 1 << _bits[i], "too big value");
            multislot_ |= _values[i];
            if (i + 1 < _bits.length) {
                multislot_ <<= _bits[i + 1];
            }
        }
    }

    /// @notice An analog of pushValuesToSlot with arrays with const (3) length as arguments
    function pushValuesToSlot(
        uint256[3] memory _values,
        uint8[3] memory _bits
    ) internal pure returns(uint256 multislot_) {
        uint16 limit;
        for (uint256 i; i < 3; i++) {
            limit += _bits[i];
            require(limit <= 256, "too many bits");
            require(_values[i] < 1 << _bits[i], "too big value");
            multislot_ |= _values[i];
            if (i + 1 < _bits.length) {
                multislot_ <<= _bits[i + 1];
            }
        }
    }

    /// @notice The most common function for creating multislot from values and their bit-lengths
    /// @dev There are analogous of this function for constant size arrays, you always can create your own just changing the [number]
    /// @dev Assembly advantage: 862 / 1820 (via Multislots.test.ts)
    /// @param _values An array of values to compress in multislot. Must be less than the corresponding 2^_bits[i]
    /// @param _bits An array of values bit-lengths respectively to _values
    /// @return multislot_ The result of the compression of the values by their bit-sizes
    function pushValuesToSlot(
        uint256[] memory _values,
        uint8[] memory _bits
    ) internal pure returns(uint256 multislot_) {
        assembly {
            if iszero(eq(mload(_values), mload(_bits))) {
                revert(0, 0)
            }
            let limit

            for { let i := 0 } lt(i, mload(_bits)) { i := add(i, 1)} {
                let ibit := mload(add(0x20, add(_bits, mul(i, 0x20))))
                let ivalue := mload(add(0x20, add(_values, mul(i, 0x20))))
                limit := add(limit, ibit)
                if gt(limit, 256) {
                    revert(0, 0)
                }
                let max := shl(ibit, 1)
                if or(gt(ivalue, max), eq(ivalue, max)) {
                    revert(0, 0)
                }

                multislot_ := or(multislot_, ivalue)
                if lt(add(i, 1), mload(_bits)) { 
                    multislot_ := shl(mload(add(0x20, add(_bits, mul(add(i, 1), 0x20)))), multislot_)
                }
            }
        }
    }

    /// @notice Pulls a value from the multislot by right-bit offset and value bit-length
    /// @param _multislot A multislot to pull value from
    /// @param _rightOffset An bit-offset from the right side of the _value: 0x|left offset|value|right offset|
    /// @param _valueBitLength How many bits value occupy in the _multislot
    /// @return value_ The pulled value
    function pullSingleValueFromSlot(
        uint256 _multislot,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) internal pure returns(uint256 value_) {
        require(uint16(_rightOffset) + uint16(_valueBitLength) <= 256, "too many bits");
        uint256 mask = ((1 << _valueBitLength) - 1 << _rightOffset);
        value_ = (_multislot & mask) >> _rightOffset;
    }

    /// @notice An analog of pullValuesFromSlot with arrays with const (2) length as arguments
    function pullValuesFromSlot(
        uint256 _multislot,
        uint8[2] memory _bits
    ) internal pure returns(uint256[2] memory values_) {
        uint16 limit;
        for (int256 i = 1; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] = (_multislot << 256 - limit) >> 256 - _bits[uint256(i)];
        }
    }

    /// @notice An analog of pullValuesFromSlot with arrays with const (2) length as arguments
    function pullValuesFromSlot(
        uint256 _multislot,
        uint8[3] memory _bits
    ) internal pure returns(uint256[3] memory values_) {
        uint16 limit;
        for (int256 i = 2; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] = (_multislot << 256 - limit) >> 256 - _bits[uint256(i)];
        }
    }

    /// @notice The most common function for getting values from the multislot by their bit sizes
    /// @dev There are analogous of this function for constant size arrays, you always can create your own just changing the [number]
    /// @param _multislot A multislot containing multiple values within itself
    /// @param _bits An array of bit-sizes which acts as layout for multislot
    /// @return values_ Values got from the multislot
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