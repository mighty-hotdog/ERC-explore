// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC6909ContentURI
 *          Interface for the Content URI extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 */
interface IERC6909ContentURI {
    function contractURI() external view returns (string memory uri);
    function tokenURI(uint256 id) external view returns (string memory uri);
}