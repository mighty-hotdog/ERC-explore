// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC677
 *          Interface for ERC677 tokens. https://github.com/ethereum/EIPs/issues/677
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC677 {
    event Transfer(address from, address to, uint256 value, bytes data);
    function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);
}