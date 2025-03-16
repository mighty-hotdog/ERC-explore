// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1155TokenReceiver
 *          Interface for the receiver contract described in the ERC1155 standard. https://eips.ethereum.org/EIPS/eip-1155
 * @author  @mighty_hotdog
 *          created 2025-03-17
 */
interface IERC1155TokenReceiver {
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
        ) external returns(bytes4);
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
        ) external returns (bytes4);
}