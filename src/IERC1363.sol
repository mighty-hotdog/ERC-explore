// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1363
 *          Interface for the ERC1363 standard. https://eips.ethereum.org/EIPS/eip-1363
 * @author  @mighty_hotdog
 *          created 2025-04-17
 *          modified 2025-04-18
 *              added comments to contract description
 *
 * @dev     The events are not specified in the standard but are specific to this implementation.
 *          These events differ from the ERC20Core events in that here the value is indexed.
 */
interface IERC1363 {
    // events
    event Transfer(address indexed from, address indexed to, uint256 indexed value, bytes data);
    event Approval(address indexed owner, address indexed spender, uint256 indexed value, bytes data);

    // functions
    function transferAndCall(address to, uint256 value) external returns (bool);
    function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) external returns (bool);
    function approveAndCall(address spender, uint256 value) external returns (bool);
    function approveAndCall(address spender, uint256 value, bytes memory data) external returns (bool);
}