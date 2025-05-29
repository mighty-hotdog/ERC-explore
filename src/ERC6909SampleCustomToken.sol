// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC6909Core} from "./ERC6909Core.sol";
import {ERC6909Metadata} from "./ERC6909Metadata.sol";
import {ERC6909ContentURI} from "./ERC6909ContentURI.sol";

/**
 * @title   ERC6909SampleCustomToken
 *          A sample ERC6909 contract.
 * @author  @mighty_hotdog
 *          created 2025-05-29
 */
contract ERC6909SampleCustomToken is ERC6909Core, ERC6909Metadata, ERC6909ContentURI {
    constructor(bytes4[] memory supportedInterfaceIds) ERC6909Core(supportedInterfaceIds) {
        _onCreation();
    }
    function createNewToken() public {
        // define new (fungible) token
        // ownership, access control, initial mint
        // name, symbol, decimals
        // tokenURI where relevant or desired
    }
    function createNewNFT() public {
        // NFTs are practically created not singly but in batches
        // NFTs also commonly belong together in collections
        // NFTs have elaborate metadata that sets each NFT apart
        // some of this metadata may change over time
    }
    function _onCreation() internal override {
        // ERC6909_CORE_INTERFACE_ID alrdy added by default in ERC6909Core constructor
        super._addSupportedInterface(ERC6909_METADATA_INTERFACE_ID);
        super._addSupportedInterface(ERC6909_CONTENT_URI_INTERFACE_ID);
    }
}