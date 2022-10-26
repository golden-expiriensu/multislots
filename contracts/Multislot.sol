// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title A library that facilitates the use of multislots
/// @notice You have to only specify the values and how many bits they should take in 256-bit slot
library Multislot {
    /// @notice Inserts value with specified bit-length and right offset to a multislot
    /// @param _multislot A multislot where value should be inserted
    /// @param _value The value to push
    /// @param _rightOffset An bit-offset from the right side of the _value: 0x|left offset|value|right offset|
    /// @param _valueBitLength How many bits value will occupy in the _multislot
    /// @return multislot_ The result of inserting
    function insertValueToSlot(
        uint256 _multislot,
        uint256 _value,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) external pure returns (uint256 multislot_) {
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

    /// @notice Function for creating multislot from values and their bit-lengths
    /// @param _values An array of values to compress in multislot. Must be less than the corresponding 2^_bits[i]
    /// @param _bits An array of values bit-lengths respectively to _values
    /// @return multislot_ The result of the compression of the values by their bit-sizes
    function packValuesToSlot(uint256[] memory _values, uint8[] memory _bits)
        external
        pure
        returns (uint256 multislot_)
    {
        assembly {
            // Make sure, that _values.length == _bits.length
            if iszero(eq(mload(_values), mload(_bits))) {
                revert(0, 0)
            }

            let limit

            for {
                let i := 0
            } lt(i, mload(_bits)) {
                i := add(i, 1)
            } {
                let ibit := mload(add(0x20, add(_bits, mul(i, 0x20))))
                let ivalue := mload(add(0x20, add(_values, mul(i, 0x20))))

                // Check if we have not exceeded 256 bit limit
                limit := add(limit, ibit)
                if gt(limit, 256) {
                    revert(0, 0)
                }
                // Check that value ∈ [0, 2^_bit[i])
                let max := shl(ibit, 1)
                if or(gt(ivalue, max), eq(ivalue, max)) {
                    revert(0, 0)
                }

                // Append value to multislot
                multislot_ := or(multislot_, ivalue)

                // Check if we have not finished with packing
                if lt(add(i, 1), mload(_bits)) {
                    // Shift multislot to right for _bits[i + 1] bits
                    multislot_ := shl(
                        mload(add(0x20, add(_bits, mul(add(i, 1), 0x20)))),
                        multislot_
                    )
                }
            }
        }
    }

    /// @notice Extracts a value from the multislot by right-bit offset and value bit-length
    /// @param _multislot A multislot to extract value from
    /// @param _rightOffset An bit-offset from the right side of the _value: 0x|left offset|value|right offset|
    /// @param _valueBitLength How many bits value occupy in the _multislot
    /// @return value_ The extracted value
    function extractSingleValueFromSlot(
        uint256 _multislot,
        uint8 _rightOffset,
        uint8 _valueBitLength
    ) external pure returns (uint256 value_) {
        require(
            uint16(_rightOffset) + uint16(_valueBitLength) <= 256,
            "too many bits"
        );
        uint256 mask = (((1 << _valueBitLength) - 1) << _rightOffset);
        value_ = (_multislot & mask) >> _rightOffset;
    }

    /// @notice Function for converting multislot to array of packed values
    /// @param _multislot A multislot
    /// @param _bits A multislot bit-layout
    /// @return values_ Values got from the multislot
    function unpackValuesFromSlot(uint256 _multislot, uint8[] memory _bits)
        external
        pure
        returns (uint256[] memory values_)
    {
        require(_bits.length > 0, "too few bits");
        values_ = new uint256[](_bits.length);
        uint16 limit;
        for (int256 i = int256(_bits.length) - 1; i >= 0; i--) {
            limit += _bits[uint256(i)];
            require(limit <= 256, "too many bits");
            values_[uint256(i)] =
                (_multislot << (256 - limit)) >>
                (256 - _bits[uint256(i)]);
        }
    }
}
