// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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