// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC6909Metadata
 *          Interface for the Metadata extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 */
interface IERC6909Metadata {
    function name(uint256 id) external view returns (string memory);
    function symbol(uint256 id) external view returns (string memory);
    function decimals(uint256 id) external view returns (uint8);
}