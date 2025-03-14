// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC165
 *          An implementation of the ERC165 standard. https://eips.ethereum.org/EIPS/eip-165
 * @author  @mighty_hotdog 2025-03-14
 *
 * @dev     This implementation uses the mapping implementation described in the ERC165 document.
 * @dev     Developers should note how ERC165 defines interfaces and how interface ids are created.
 * @dev     The (unfortunate) choice of certain names in the ERC165 document may cause some confusion wrt the naming of files.
 *          For this implementation, the files are organized and named as follows:
 *          - IERC165.sol: interface
 *          - ERC165.sol: implementation, as an abstract contract to be inherited
 */
abstract contract ERC165 {
    // constants
    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;  // interface id for ERC165 interface
    bytes4 internal constant NULL_INTERFACE_ID = 0xffffffff;

    // state variables
    mapping(bytes4 => bool) private supportedInterfaces;    // stores whether an interface is supported by this contract

    /**
     * @notice  constructor()
     *          Adds the ERC165 interface, as well as any interfaces provided, to the list of supported interfaces.
     * @param   interfaceIds    array of interface identifiers to be added to supported list
     *
     * @dev     The ERC165 interface id need not be included in the interfaceIds array. It will be added by default in construction.
     * @dev     Logic is shifted to _onCreation() to facilitate overriding if desired.
     * @dev     Reverts if 0xffffffff is included in the interfaceIds array.
     */
    constructor(bytes4[] memory interfaceIds) {
        _onCreation(interfaceIds);
    }

    /**
     * @notice  supportsInterface()
     *          Checks if this contract implements an interface.
     * @param   interfaceId the interface identifier that describes the interface to be checked
     * @dev     As specified in the ERC165 standard, this function returns:
     *          - true for interfaceId == 0x01ffc9a7, this being the interface id for the ERC165 interface
     *          - false for interfaceId == 0xffffffff
     *          - true for any interfaceId that is implemented by this contract
     *          - false for any other interfaceId
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return supportedInterfaces[interfaceId];
    }

    /**
     * @notice  _onCreation()
     *          Contains logic for the constructor.
     *          Adds the ERC165 interface by default, as well as any other interfaces provided, to the list of supported interfaces.
     * @param   interfaceIds    array of interface identifiers to be added to supported list
     * @dev     Reverts if 0xffffffff is included in the interfaceIds array.
     */
    function _onCreation(bytes4[] memory interfaceIds) internal virtual {
        _addSupportedInterface(ERC165_INTERFACE_ID);
        _addAllSupportedInterfaces(interfaceIds);
    }

    /**
     * @notice  _addAllSupportedInterfaces()
     *          Adds an array of interfaces to the list of supported interfaces.
     * @param   interfaceIds    array of interface identifiers to be added to supported list
     * @dev     Reverts if 0xffffffff is included in the interfaceIds array.
     */
    function _addAllSupportedInterfaces(bytes4[] memory interfaceIds) internal virtual {
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            _addSupportedInterface(interfaceIds[i]);
        }
    }

    /**
     * @notice  _addSupportedInterface()
     *          Adds an interface to the list of supported interfaces.
     * @param   interfaceId interface identifier of the interface to be added
     * @dev     Reverts if interfaceId == 0xffffffff.
     */
    function _addSupportedInterface(bytes4 interfaceId) internal virtual {
        if (interfaceId == NULL_INTERFACE_ID) {
            revert("ERC165: trying to add invalid interface id (0xffffffff)");
        }
        supportedInterfaces[interfaceId] = true;
    }
}