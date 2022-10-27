// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Multislot} from "./Multislot.sol";

import "hardhat/console.sol";

/// @title Library to make gas price for the first storage write as small as possible
/// @dev WARNING: Use this library only for storage INITIALIZATION. Not CRUD, but CRD
/// @dev For instance: it is viable for writing data for on-chain NFT, since it unlikely
/// @dev But if you will use it for variable that may be changed you can increase gas cost
library AdjacentMultislots {
    using Multislot for uint256;

    uint256 constant zero = 0;

    /// @param _atSlot Values will be packed and written to adjacent slots starting from _atSlot
    /// @param _values Values that have to be packed and written
    /// @param _bitsLayout Bit length of _values
    function writeValues(
        uint256 _atSlot,
        uint256[] memory _values,
        uint256[] memory _bitsLayout
    ) internal {
        uint256 currentMultislotBitsOccupied;
        uint256 currentMultislot;

        for (uint256 i; i < _values.length; i++) {
            currentMultislotBitsOccupied += _bitsLayout[i];

            if (currentMultislotBitsOccupied > 256) {
                uint256 surplusBits = currentMultislotBitsOccupied - 256;
                uint256 crammedBits = _bitsLayout[i] - surplusBits;

                uint256 appendToCurrentSlot = _values[i] >> surplusBits;
                uint256 prependToNextSlot = _values[i] -
                    (appendToCurrentSlot << surplusBits);

                currentMultislot = currentMultislot.insertValue(
                    appendToCurrentSlot,
                    0,
                    crammedBits
                );

                assembly {
                    sstore(_atSlot, currentMultislot)
                }

                currentMultislotBitsOccupied = surplusBits;
                currentMultislot = zero.insertValue(
                    prependToNextSlot,
                    256 - surplusBits,
                    surplusBits
                );
                _atSlot++;
            } else if (currentMultislotBitsOccupied == 256) {
                assembly {
                    sstore(_atSlot, currentMultislot)
                }

                currentMultislotBitsOccupied = 0;
                currentMultislot = 0;
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
}
