// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1363Spender
 *          Interface for the ERC1363Spender standard. https://eips.ethereum.org/EIPS/eip-1363
 * @author  @mighty_hotdog 2025-04-17
 */
interface IERC1363Spender {
    function onApprovalReceived(address owner, uint256 value, bytes memory data) external returns (bytes4);
}