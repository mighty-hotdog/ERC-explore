// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC6909ContentURI
 *          Implementation of the Content URI extension of the ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 *          modified 2025-05-28
 *              completed contract implementation
 * @dev     Very basic braindead simplistic implementation.
 */
abstract contract ERC6909ContentURI {
    // constants //////////////////////////////////////////////////////////////////////////
    // contracts that inherit this ERC6909ContentURI contract must add this interface id to their list of supported interfaces
    bytes4 public constant ERC6909_CONTENT_URI_INTERFACE_ID = 
        bytes4(keccak256("contractURI()")) ^
        bytes4(keccak256("tokenURI(uint256)"));

    // variables //////////////////////////////////////////////////////////////////////////
    string private contractUri;
    mapping(uint256 => string) private tokenUri;

    // functions //////////////////////////////////////////////////////////////////////////
    /**
     * @notice  contractURI()
     *          Returns the contract URI.
     * @dev     Getter function. Never reverts.
     */
    function contractURI() external view virtual returns (string memory uri) {
        return contractUri;
    }

    /**
     * @notice  tokenURI()
     *          Returns the URI for the token of type `id`.
     * @dev     Getter function. Never reverts.
     */
    function tokenURI(uint256 id) external view virtual returns (string memory uri) {
        return tokenUri[id];
    }

    /**
     * @notice  setContractURI()
     *          Sets the contract URI.
     * @dev     Not specified in the standard, but added to this implementation because it is obviously necessary.
     */
    function setContractURI(string memory _contractUri) public virtual {
        contractUri = _contractUri;
    }
    
    /**
     * @notice  setTokenURI()
     *          Sets the URI for the token of type `id`.
     * @dev     Not specified in the standard, but added to this implementation because it is obviously necessary.
     */
    function setTokenURI(uint256 id, string memory _tokenUri) public virtual {
        tokenUri[id] = _tokenUri;
    }
}