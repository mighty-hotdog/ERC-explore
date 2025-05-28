// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC6909Metadata
 *          Implementation for the Metadata extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-28
 * @dev     Very basic braindead simplistic implementation.
 */
abstract contract ERC6909Metadata {
    // constants //////////////////////////////////////////////////////////////////////////
    // contracts that inherit this ERC6909Metadata contract must add this interface id to their list of supported interfaces
    bytes4 public constant ERC6909_METADATA_INTERFACE_ID = 
        bytes4(keccak256("name(uint256)")) ^
        bytes4(keccak256("symbol(uint256)")) ^
        bytes4(keccak256("decimals(uint256)"));

    // variables //////////////////////////////////////////////////////////////////////////
    mapping(uint256 => string) private tokenNames;
    mapping(uint256 => string) private tokenSymbols;
    mapping(uint256 => uint8) private tokenDecimals;

    // functions //////////////////////////////////////////////////////////////////////////
    function name(uint256 id) public view virtual returns (string memory) {
        return tokenNames[id];
    }
    function symbol(uint256 id) public view virtual returns (string memory) {
        return tokenSymbols[id];
    }
    function decimals(uint256 id) public view virtual returns (uint8) {
        return tokenDecimals[id];
    }

    // the following 3 functions are not specified in the standard but are obviously necessary
    function setName(uint256 id, string memory _name) public virtual {
        tokenNames[id] = _name;
    }
    function setSymbol(uint256 id, string memory _symbol) public virtual {
        tokenSymbols[id] = _symbol;
    }
    function setDecimals(uint256 id, uint8 _decimals) public virtual {
        tokenDecimals[id] = _decimals;
    }
}