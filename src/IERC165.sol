// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC165
 *          Interface for the ERC-165 standard. https://eips.ethereum.org/EIPS/eip-165
 * @author  @mighty_hotdog 2025-03-14
 *
 * @dev     The (unfortunate) choice of certain names in the ERC165 document may cause some confusion wrt the naming of files.
 *          For this implementation, the files are organized and named as follows:
 *          - IERC165.sol: interface
 *          - ERC165.sol: implementation, as an abstract contract to be inherited
 */
interface IERC165 {
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
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}