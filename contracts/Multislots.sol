// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Multislots {
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