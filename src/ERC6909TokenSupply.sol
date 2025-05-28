// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC6909TokenSupply
 *          Implementation for the Token Supply extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-28
 * @dev     Very basic braindead simplistic implementation.
 */
abstract contract ERC6909TokenSupply {
    // constants //////////////////////////////////////////////////////////////////////////
    // contracts that inherit this ERC6909TokenSupply contract must add this interface id to their list of supported interfaces
    bytes4 public constant ERC6909_TOKEN_SUPPLY_INTERFACE_ID = bytes4(keccak256("totalSupply(uint256)"));

    // variables //////////////////////////////////////////////////////////////////////////
    mapping(uint256 => uint256) private tokenSupply;

    // functions //////////////////////////////////////////////////////////////////////////
    function totalSupply(uint256 id) public view virtual returns (uint256 supply) {
        return tokenSupply[id];
    }

    // the following function is not specified in the standard but is obviously necessary
    function setTotalSupply(uint256 id, uint256 _supply) public virtual {
        tokenSupply[id] = _supply;
    }
}