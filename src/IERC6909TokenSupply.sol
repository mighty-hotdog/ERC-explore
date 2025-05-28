// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC6909TokenSupply
 *          Interface for the Token Supply extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 */
interface IERC6909TokenSupply {
    function totalSupply(uint256 id) external view returns (uint256 supply);
}