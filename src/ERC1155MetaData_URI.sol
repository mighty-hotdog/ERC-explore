// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC1155Metadata_URI
 *          An implementation for the optional ERC1155Metadata_URI extension described in the ERC1155 standard.
 *          https://eips.ethereum.org/EIPS/eip-1155#metadata
 * @author  @mighty_hotdog
 *          created 2025-03-18
 *          modified 2025-04-10
 *              made `_trailer` a constant
 */
abstract contract ERC1155Metadata_URI {
    /**
     * @notice  _baseURI
     *          Base URI, combines with the token id to form the token metadata URI.
     * @dev     Set in constructor. Intended to be set only once.
     *
     *          Note the ERC1155 standard's specification that the token id, as used in the URI, is a 
     *          hexadecimal byte array padded to 64 characters.
     */
    bytes private _baseURI;
    bytes private constant _trailer = ".json";

    /**
     * @notice  constructor()
     *          Generates and sets the base URI for calculating the token metadata URI.
     * @param   str  byte string, to be used in the generation of the base URI
     *
     * @dev     Logic is shifted to _generateBaseURI() to allow overriding with implementation specific logic as desired.
     */
    constructor(bytes memory str) {
        _generateBaseURI(str);
    }

    /**
     * @notice  uri()
     *          Returns the token metadata URI.
     * @param   id  token id
     */
    function uri(uint256 id) public virtual returns (string memory) {
        return string(_generateTokenURI(id));
    }

    /**
     * @notice  _generateBaseURI()
     *          Generates the base URI using the byte string input.
     * @param   str  byte string
     */
    function _generateBaseURI(bytes memory str) internal virtual {
        _baseURI = str;
    }

    /**
     * @notice  _generateTokenURI()
     *          Generates the token metadata URI.
     */
    function _generateTokenURI(uint256 id) internal virtual returns (bytes memory) {
        return bytes.concat(_baseURI, _generatePaddedTokenId(id), _trailer);
    }

    /**
     * @notice  _generatePaddedTokenId()
     *          Generates the padded token id byte array.
     * @param   id  token id
     *
     * @dev     The token id, as used in the URI, is a hexadecimal byte array padded to 64 characters.
     *          This function takes the uint256 token id input and converts it into a byte array padded to 64 bytes.
     */
    function _generatePaddedTokenId(uint256 id) internal virtual returns (bytes memory) {
        bytes memory tokid = abi.encodePacked(id);
        uint256 paddingNeeded = 64 - tokid.length;  // padding needed to pad token id bytes array up to 64 bytes
        bytes memory padding = new bytes(paddingNeeded);    // the actual padding bytes
        // return padded token id string
        return bytes.concat(padding,tokid,".json");
    }
}