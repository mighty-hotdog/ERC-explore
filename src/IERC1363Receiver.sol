// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC1363Receiver {
    function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4);
}