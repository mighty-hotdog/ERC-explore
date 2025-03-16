// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1155Metadata_URI
 *          Interface for the optional ERC1155Metadata_URI extension described in the ERC1155 standard.
 *          https://eips.ethereum.org/EIPS/eip-1155#metadata
 * @author  @mighty_hotdog
 *          created 2025-03-17
 */
interface IERC1155Metadata_URI {
    function uri(uint256 _id) external view returns (string memory);
}