// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC677Receiver
 *          Interface for contracts that want to receive ERC677 tokens.
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC677Receiver {
    function onTokenTransfer(address from, uint256 value, bytes memory data) external returns (bool);
}