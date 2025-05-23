// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC6909ContentURI
 *          Implementation of the Content URI extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 *          INCOMPLETE
 */
abstract contract ERC6909ContentURI {
    // variables //////////////////////////////////////////////////////////////////////////
    string private contractUri;
    string private tokenUri;

    // functions //////////////////////////////////////////////////////////////////////////
    function contractURI() external view virtual returns (string memory uri) {
        return contractUri;
    }
    function tokenURI(uint256 id) external view virtual returns (string memory uri) {
        return contractUri;
    }
}