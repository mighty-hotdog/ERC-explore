// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC165} from "./IERC165.sol";

/**
 * @title   IERC6909Core
 *          Interface for the core ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 */
interface IERC6909Core {
    // events ///////////////////////////////////////////////////////////////////////////
    event Transfer(address caller, address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount);
    event OperatorSet(address indexed owner, address indexed spender, bool approved);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);

    // functions ////////////////////////////////////////////////////////////////////////
    function balanceOf(address owner, uint256 id) external view returns (uint256 amount);
    function allowance(address owner, address spender, uint256 id) external view returns (uint256 amount);
    function isOperator(address owner, address spender) external view returns (bool status);
    function transfer(address receiver, uint256 id, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 id, uint256 amount) external returns (bool success);
    function setOperator(address spender, bool approved) external returns (bool success);
}