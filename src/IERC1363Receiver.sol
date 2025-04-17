// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1363Receiver
 *          Interface for the ERC1363Receiver standard. https://eips.ethereum.org/EIPS/eip-1363
 * @author  @mighty_hotdog 2025-04-17
 */
interface IERC1363Receiver {
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4);
}