// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC1155
 *          Interface for the ERC1155 standard. https://eips.ethereum.org/EIPS/eip-1155
 * @author  @mighty_hotdog
 *          created 2025-03-17
 */
interface IERC1155 {
    // events
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    // functions
    function safeTransferFrom(
        address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data
        ) external;
    function safeBatchTransferFrom(
        address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) external;
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}