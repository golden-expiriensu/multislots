pragma solidity ^0.8.4;

import "./Multislots.sol";

contract TestContract {
    using Multislots for uint256;
    using Multislots for uint256[];

    uint256 multislot;

    function setValuesToSlot(
        uint256[] calldata _values,
        uint8[] calldata _bits
    ) external {
        multislot = _values.pushValuesToSlot(_bits);
    }

    function getValuesFromSlot(
        uint8[] calldata _bits
    ) external view returns(uint256[] memory values_) {
        values_ = multislot.pullValuesFromSlot(_bits);
    }
}