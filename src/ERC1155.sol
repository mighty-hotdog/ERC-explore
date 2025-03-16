// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC1155} from "./IERC1155.sol";
import {IERC1155Metadata_URI} from "./IERC1155Metadata_URI.sol";
import {ERC165} from "./ERC165.sol";
import {IERC1155TokenReceiver} from "./IERC1155TokenReceiver.sol";

/**
 * @title   ERC1155
 *          An implementation of the ERC1155 standard. https://eips.ethereum.org/EIPS/eip-1155
 * @author  @mighty_hotdog
 *          created 2025-03-17
 *
 * @dev     Outstanding TODOs:
 *          1. Check that all "rules" as defined in the ERC1155 standard have been implemented and are correct.
 *          2. Implement URI function.
 *          3. Implement the mint and burn functions.
 *          4. Add reentrancy protection.
 *          5. Add a sample ERC1155 contract that brings everything together in a working contract.
 *          6. Add a sample ERC1155TokenReceiver contract that implements IERC1155TokenReceiver.
 */
abstract contract ERC1155 is IERC1155, IERC1155Metadata_URI, ERC165 {
    // constants //////////////////////////////////////////////////////////////////////////
    // interfaceids to be added to ERC165 supported list
    bytes4 public constant ERC1155_INTERFACE_ID = 0xd9b67a26;
    bytes4 public constant ERC1155_METADATA_URI_INTERFACE_ID = 0x0e89341c;

    // ERC1155 receiver return values indicating transfer accepted
    bytes4 public constant ERC1155_SINGLE_TRANSFER_ACCEPTED = 
        bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    bytes4 public constant ERC1155_BATCH_TRANSFER_ACCEPTED = 
        bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    
    // state variables ////////////////////////////////////////////////////////////////////
    mapping(address owner => mapping(uint256 id => uint256 value)) private _balances;
    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    // functions //////////////////////////////////////////////////////////////////////////
    /**
     * @notice  constructor()
     * @param   supportedInterfaces array of supported interfaces
     * @dev     No need to include ERC1155 and ERC1155Metadata_URI interfaces in input array.
     *          They will be added by default.
     */
    constructor(bytes4[] memory supportedInterfaces) ERC165(supportedInterfaces) {
        super._addSupportedInterface(ERC1155_INTERFACE_ID);
        super._addSupportedInterface(ERC1155_METADATA_URI_INTERFACE_ID);
    }

    /**
     * @notice  safeTransferFrom()
     *          Transfers `_value` amount of tokens of type `_id` from `_from` address to `_to` address.
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to transfer
     * @param   _data   optional data
     *
     * @dev     Logic shifted to _safeTransferFrom() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender == an "operator" aka "spender" for the `_from` address.
     * @dev     Reverts if caller is not an approved operator for `_from`.
     * @dev     Reverts if _to == address(0).
     * @dev     Reverts if _value > balanceOf(_from, _id).
     * @dev     Emits TransferSingle() event on successful token transfer.
     * @dev     If _to is a contract:
     *          Calls onERC1155Received() on _to contract and checks return value.
     *          Reverts if return value is not ERC1155_SINGLE_TRANSFER_ACCEPTED.
     */
    function safeTransferFrom(
        address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data
        ) public virtual {
        _safeTransferFrom(_from, _to, _id, _value, _data);
    }

    /**
     * @notice  safeBatchTransferFrom()
     *          Transfers `[]_values` amounts of tokens of types `[]_ids` from `_from` address to `_to` address.
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _ids    array of token IDs to transfer
     * @param   _values array of amounts of each token to transfer
     * @param   _data   optional data
     *
     * @dev     Logic shifted to _safeBatchTransferFrom() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender == an "operator" aka "spender" for the `_from` address.
     * @dev     Reverts if caller is not an approved operator for `_from`.
     * @dev     Reverts if _to == address(0).
     * @dev     Reverts if _ids.length != _values.length.
     * @dev     Reverts if a value in []_values array > that the owner balance for the corresponding token ID.
     * @dev     Emits TransferBatch() event on successful transfer for every token.
     * @dev     If _to is a contract:
     *          Calls onERC1155BatchReceived() on _to contract and checks return value.
     *          Reverts if return value is not ERC1155_BATCH_TRANSFER_ACCEPTED.
     */
    function safeBatchTransferFrom(
        address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) public virtual {
        _safeBatchTransferFrom(_from, _to, _ids, _values, _data);
    }

    /**
     * @notice  balanceOf()
     *          Returns the amount of tokens of type `_id` owned by `_owner` address.
     * @param   _owner  owner address to query
     * @param   _id     token ID to query
     *
     * @dev     Getter function that should never revert. But what if _owner == address(0)?
     */
    function balanceOf(address _owner, uint256 _id) public view virtual returns (uint256) {
        return _balances[_owner][_id];
    }

    /**
     * @notice  balanceOfBatch()
     *          Returns the amount of tokens of types `[]_ids` owned by `[]_owners`.
     * @param   _owners array of owner addresses to query
     * @param   _ids    array of token IDs to query
     *
     * @dev     Getter function that should never revert. But what if any of the owners == address(0)?
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) public view virtual returns (uint256[] memory) {
        uint256[] memory values = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            values[i] = _balances[_owners[i]][_ids[i]];
        }
        return values;
    }

    /**
     * @notice  setApprovalForAll()
     *          Sets an "operator" to be an approved or non-approved operator for the caller.
     * @param   _operator   operator address
     * @param   _approved   true == approved, false == not approved
     *
     * @dev     Caller == msg.sender == owner of the tokens.
     * @dev     Reverts if _operator == address(0).
     * @dev     Emits ApprovalForAll() event.
     */
    function setApprovalForAll(address _operator, bool _approved) public virtual {
        _updateApprovals(msg.sender, _operator, _approved);
    }

    /**
     * @notice  isApprovedForAll()
     *          Returns true if the operator is an approved operator for the owner. Otherwise returns false.
     * @param   _owner      owner address
     * @param   _operator   operator address
     *
     * @dev     Getter function that should never revert.
     * @dev     Returns false if _owner == address(0) or _operator == address(0).
     */
    function isApprovedForAll(address _owner, address _operator) public view virtual returns (bool) {
        // return false if invalid owner or operator
        if ((_owner == address(0)) || (_operator == address(0))) {
            return false;
        }
        return _operatorApprovals[_owner][_operator];
    }

    /**
     * @notice  _safeTransferFrom()
     *          Contains the logic from safeTransferFrom().
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to transfer
     * @param   _data   optional data
     */
    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) internal virtual {
        if (_operatorApprovals[_from][msg.sender] == false) {
            revert("ERC1155: caller is not an approved operator for the sender");
        }
        if (_to == address(0)) {
            revert("ERC1155: transfer to address(0)");
        }
        // perform safeTransfer
        _updateBalances(_from, _to, _id, _value);
        // emit TransferSingle
        emit TransferSingle(msg.sender, _from, _to, _id, _value);
        // check if recipient is a contract
        if (isContract(_to)) {
            // call onERC1155Received() and check return value
            if (IERC1155TokenReceiver(_to).onERC1155Received(_from, _to, _id, _value, _data) != ERC1155_SINGLE_TRANSFER_ACCEPTED) {
                revert("ERC1155: transfer not accepted by receiver contract");
            }
        }
    }

    /**
     * @notice  _safeBatchTransferFrom()
     *          Contains the logic from safeBatchTransferFrom().
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _ids    array of token IDs to transfer
     * @param   _values array of amounts of each token to transfer
     * @param   _data   optional data
     */
    function _safeBatchTransferFrom(
        address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) internal virtual {
        if (_operatorApprovals[_from][msg.sender] == false) {
            revert("ERC1155: caller is not an approved operator for the sender");
        }
        if (_to == address(0)) {
            revert("ERC1155: transfer to address(0)");
        }
        if (_ids.length != _values.length) {
            revert("ERC1155: ids and values array lengths mismatch");
        }
        // perform safeBatchTransfer
        for (uint256 i = 0; i < _ids.length; i++) {
            _updateBalances(_from, _to, _ids[i], _values[i]);
        }
        // emit TransferBatch
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
        // check if recipient is a contract
        if (isContract(_to)) {
            // call onERC1155BatchReceived() and check return value
            if (IERC1155TokenReceiver(_to).onERC1155BatchReceived(_from, _to, _ids, _values, _data) != ERC1155_BATCH_TRANSFER_ACCEPTED) {
                revert("ERC1155: batch transfer not accepted by receiver contract");
            }
        }
    }

    /**
     * @notice  _updateBalances()
     *          Updates the owner and receiver token balances.
     * @param   _from   source aka owner address tokens are sent from
     * @param   _to     receiver address tokens are sent to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to transfer
     *
     * @dev     This function is intended to be the only place where balances are modified.
     *          As such, its design is solely focused on correctly updating the balances, including all error checks
     *          and logic needed to perform these operations correctly.
     *          eg: balance < _value, overflow/underflow
     * @dev     Application logic, such as address restrictions, approvals, reentrancy, etc. to be handled by higher
     *          level functions that implement those logic, and then call this function to effect the updates.
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _value > _balances[_from, _id].
     * @dev     Reverts on arithmetic overflow/underflow when calc balances.
     */
    function _updateBalances(address _from, address _to, uint256 _id, uint256 _value) internal virtual {
        if (_value > balanceOf(_from, _id)) {
            revert("ERC1155: sender insufficient balance");
        }
        _balances[_from][_id] -= _value;
        _balances[_to][_id] += _value;
    }

    /**
     * @notice  _updateApprovals()
     *          Contains the logic from setApprovalForAll().
     * @param   _owner      owner address
     * @param   _operator   operator address
     * @param   _approved   approval status, true == approved, false == not approved
     *
     * @dev     This function is intended to be the only place where approvals are modified.
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _owner == address(0).
     * @dev     Reverts if _operator == address(0).
     * @dev     Emits ApprovalForAll() event.
     */
    function _updateApprovals(address _owner, address _operator, bool _approved) internal virtual {
        if (_owner == address(0)) {
            revert("ERC1155: invalid owner address(0)");
        }
        if (_operator == address(0)) {
            revert("ERC1155: invalid operator address(0)");
        }
        _operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    /**
     * @notice  isContract()
     *          Returns true if the address is a contract.
     * @param   addr    address to check
     * @dev     Utility function. Should never revert.
     * @dev     Uses assembly.
     */
    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}