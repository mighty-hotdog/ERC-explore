// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC6909TokenSupply
 *          Interface for the Token Supply extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 *          modified 2025-05-28
 *              added comments explaining the seeming redundancy of this extension and that it will not be used
 *
 * @dev     This functionality should not be implemented as an optional extension since token supply is integral to every
 *          token type.
 *          Token supply mechanics (mirroring this extension) has been included in the ERC6909 core contract implementation
 *          in ERC6909Core.sol. As such, this interface and its associated implementation are included here merely for
 *          completeness and will not be used.
 */
interface IERC6909TokenSupply {
    function totalSupply(uint256 id) external view returns (uint256 supply);
}