// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC6909TokenSupply
 *          Implementation for the Token Supply extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-28
 * @dev     Very basic braindead simplistic implementation.
 *
 * @dev     This functionality should not be implemented as an optional extension since token supply is integral to every
 *          token type.
 *          Token supply mechanics (mirroring this extension) has been included in the ERC6909 core contract implementation
 *          in ERC6909Core.sol. As such, this implementation and its associated interface are included here merely for
 *          completeness and will not be used.
 */
abstract contract ERC6909TokenSupply {
    // constants //////////////////////////////////////////////////////////////////////////
    // inheriting contracts to add this interface id to their list of supported interfaces
    bytes4 public constant ERC6909_TOKEN_SUPPLY_INTERFACE_ID = bytes4(keccak256("totalSupply(uint256)"));

    // variables //////////////////////////////////////////////////////////////////////////
    mapping(uint256 => uint256) private tokenSupply;

    // functions //////////////////////////////////////////////////////////////////////////
    function totalSupply(uint256 id) public view virtual returns (uint256 supply) {
        return tokenSupply[id];
    }
}