// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Multislot} from "./Multislot.sol";

/// @title This library makes gas price for storing values, less than 256 bits, as small as possible
/// @dev WARNING: Use this library only for storage INITIALIZATION. Not CRUD, but CRD, check for details in ExampleContract
library AdjacentMultislots {
    using Multislot for uint256;

    uint256 constant zero = 0;

    /// @notice Packs _values in according to _bitsLayout as tight as it possible and stores packed result to storage
    /// @param _atSlot Values will be packed and written to adjacent slots starting from _atSlot
    /// @param _values Values that have to be packed and written
    /// @param _bitsLayout Bit length of _values
    function write(
        uint256 _atSlot,
        uint256[] memory _values,
        uint256[] memory _bitsLayout
    ) internal {
        uint256 currentMultislotBitsOccupied;
        uint256 currentMultislot;

        for (uint256 i; i < _values.length; i++) {
            currentMultislotBitsOccupied += _bitsLayout[i];

            if (currentMultislotBitsOccupied >= 256) {
                uint256 surplusBits = currentMultislotBitsOccupied - 256;
                uint256 fitBits = _bitsLayout[i] - surplusBits;

                uint256 fitToCurrentMultislot = _values[i] >> surplusBits;
                uint256 pushToNextMultislot = _values[i] -
                    (fitToCurrentMultislot << surplusBits);

                currentMultislot = currentMultislot.insertValue(
                    fitToCurrentMultislot,
                    0,
                    fitBits
                );

                assembly {
                    sstore(_atSlot, currentMultislot)
                }

                currentMultislotBitsOccupied = surplusBits;
                currentMultislot = surplusBits > 0
                    ? zero.insertValue(
                        pushToNextMultislot,
                        256 - surplusBits,
                        surplusBits
                    )
                    : 0;
                _atSlot++;
            } else {
                currentMultislot = currentMultislot.insertValue(
                    _values[i],
                    256 - currentMultislotBitsOccupied,
                    _bitsLayout[i]
                );
            }
        }

        if (currentMultislot != 0)
            assembly {
                sstore(_atSlot, currentMultislot)
            }
    }

    /// @notice Reads storage and extracts packed values in according to _bitsLayout
    /// @param _atSlot Values will be extracted from storage starting from _atSlot
    /// @param _bitsLayout Bit length of values_
    /// @return values_ Values that have been extracted from storage multislots
    function read(uint256 _atSlot, uint256[] memory _bitsLayout)
        internal
        view
        returns (uint256[] memory values_)
    {
        values_ = new uint256[](_bitsLayout.length);
        int256 rightOffset = 256;

        for (uint256 i; i < _bitsLayout.length; i++) {
            uint256 iSlot;
            assembly {
                iSlot := sload(_atSlot)
            }

            require(_bitsLayout[i] <= 256);
            rightOffset -= int256(_bitsLayout[i]);

            if (rightOffset < 0) {
                uint256 bitSurplus = uint256(-rightOffset);

                values_[i] =
                    iSlot.extractSingleValue(0, _bitsLayout[i] - bitSurplus) <<
                    bitSurplus;

                _atSlot++;
                assembly {
                    iSlot := sload(_atSlot)
                }

                rightOffset = 256 - int256(bitSurplus);

                values_[i] |= iSlot.extractSingleValue(
                    uint256(rightOffset),
                    bitSurplus
                );
            } else {
                values_[i] = iSlot.extractSingleValue(
                    uint256(rightOffset),
                    _bitsLayout[i]
                );

                if (rightOffset == 0) rightOffset = 256;
            }
        }
    }
}
