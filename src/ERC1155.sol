// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC1155} from "./IERC1155.sol";
import {ERC1155Metadata_URI} from "./ERC1155MetaData_URI.sol";
import {ERC165} from "./ERC165.sol";
import {IERC1155TokenReceiver} from "./IERC1155TokenReceiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title   ERC1155
 *          An implementation of the ERC1155 standard. https://eips.ethereum.org/EIPS/eip-1155
 * @author  @mighty_hotdog
 *          created 2025-03-17
 *          modified 2025-03-18
 *              added OpenZep's ReentrancyGuard for reentrancy protection
 *              added mint(), mintBatch(), burn(), burnBatch() functions, with their associated internal functions
 *              modified _updateBalances() to perform mint and burn operations
 *              updated contract to inherit from ERC1155Metadata_URI (implementation) instead of IERC1155Metadata_URI (interface)
 *              modified transferFrom() and transferBatchFrom() to:
 *                  - allow owner to transfer own tokens without need for approval
 *                  - revert on _from == address(0), this logic is specific to this implementation
 *
 * @dev     Outstanding TODOs:
 *          1. DONE Check that all "rules" as defined in the ERC1155 standard have been implemented and are correct.
 *          2. DONE Implement URI function.
 *          3. DONE Implement the mint and burn functions.
 *          4. DONE Add reentrancy protection.
 *              Added OpenZep's ReentrancyGuard, but is it enough?
 *              How about an OnlyOneCallGuard that offers:
 *              - contract-wide reentrancy guard (like ReentrancyGuard)
 *              - function-specific reentrancy guard
 *              - flow-specific reentrancy guard
 *                ie: specify a particular function flow, then define and apply a reentrancy guard to that flow
 *          5. NOT NEEDED Add a sample ERC1155 contract that brings everything together in a working contract.
 *          6. NOT NEEDED Add a sample ERC1155TokenReceiver contract that implements IERC1155TokenReceiver.
 *
 * @dev     Question: How to ensure states are in-sync between the ERC1155 contract and the individual token contracts?
 *          eg: total token supply, balances, approvals/allowances, etc.
 *          Similiar issue encountered in ERC20Wrapper.
 *          Expected wherever there are multiple mutually-independent sets of methods (as in different contracts) that
 *          modify the same states.
 *
 *          Is this actually a real problem? Are there actually "individual token contracts" to manage? Or are the tokens
 *          managed on ERC1155 contracts all created and managed on the same ERC1155 contract with no separate individual
 *          token contracts?
 *          OpenZep's ERC1155 implementation doesn't even mention this.

 *          Do the major protocols like Uniswap, AAVE, handle this? How?
 */
abstract contract ERC1155 is IERC1155, ERC1155Metadata_URI, ERC165, ReentrancyGuard {
    // constants //////////////////////////////////////////////////////////////////////////
    // ERC1155 interface IDs to be added by default to ERC165 supported list
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
     *          Constructor adds them by default.
     */
    constructor(bytes memory baseURI, bytes4[] memory supportedInterfaces) ERC1155Metadata_URI(baseURI) ERC165(supportedInterfaces) {
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
     * @dev     Reverts if caller != `_from` and caller is not an approved operator for `_from`.
     * @dev     Reverts if _from == address(0). Not specified in the standard but is specific to this implementation.
     * @dev     Reverts if _to == address(0).
     * @dev     Reverts if _value > balanceOf(_from, _id).
     * @dev     Emits TransferSingle() event on successful token transfer.
     * @dev     If _to is a contract:
     *          Calls onERC1155Received() on _to contract and checks return value.
     *          Reverts if onERC1155Received() return value is not ERC1155_SINGLE_TRANSFER_ACCEPTED.
     */
    function safeTransferFrom(
        address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data
        ) public virtual nonReentrant {
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
     * @dev     Reverts if caller != `_from` and caller is not an approved operator for `_from`.
     * @dev     Reverts if _from == address(0). Not specified in the standard but is specific to this implementation.
     * @dev     Reverts if _to == address(0).
     * @dev     Reverts if _ids.length != _values.length.
     * @dev     Reverts if a value in []_values array > the owner balance for the corresponding token ID.
     * @dev     Emits TransferBatch() event on successful transfer for every token.
     * @dev     If _to is a contract:
     *          Calls onERC1155BatchReceived() on _to contract and checks return value.
     *          Reverts if onERC1155BatchReceived() return value is not ERC1155_BATCH_TRANSFER_ACCEPTED.
     */
    function safeBatchTransferFrom(
        address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) public virtual nonReentrant {
        _safeBatchTransferFrom(_from, _to, _ids, _values, _data);
    }

    /**
     * @notice  mint()
     *          Mints `_value` amount of tokens of type `_id` to `_to` address.
     * @param   _to     receiver address to mint to
     * @param   _id     token ID to mint
     * @param   _value  amount of tokens to mint
     * @param   _data   optional data
     *
     * @dev     The standard doesn't explicitly specify mint functions but aludes to them as something necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic shifted to _mint() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _to == address(0).
     * @dev     Emits TransferSingle() event on successful mint.
     * @dev     If _to is a contract:
     *          Calls onERC1155Received() on _to contract and checks return value.
     *          Reverts if onERC1155Received() return value is not ERC1155_SINGLE_TRANSFER_ACCEPTED.
     */
    function mint(
        address _to, uint256 _id, uint256 _value, bytes calldata _data
        ) public virtual nonReentrant {
        _mint(_to, _id, _value, _data);
    }

    /**
     * @notice  mintBatch()
     *          Mints `[]_values` amounts of tokens of types `[]_ids` to `_to` address.
     * @param   _to     receiver address to mint to
     * @param   _ids    array of token IDs to mint
     * @param   _values array of amounts of tokens to mint
     * @param   _data   optional data
     *
     * @dev     The standard doesn't explicitly specify mint functions but aludes to them as something necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic shifted to _mintBatch() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _to == address(0).
     * @dev     Reverts if _ids.length != _values.length.
     * @dev     Emits TransferBatch() event if every token mint is successful.
     * @dev     If _to is a contract:
     *          Calls onERC1155BatchReceived() on _to contract and checks return value.
     *          Reverts if onERC1155BatchReceived() return value is not ERC1155_BATCH_TRANSFER_ACCEPTED.
     */
    function mintBatch(
        address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) public virtual nonReentrant {
        _mintBatch(_to, _ids, _values, _data);
    }

    /**
     * @notice  burn()
     *          Burns `_value` amount of tokens of type `_id` from `_from` address.
     * @param   _from   source aka owner address to burn from
     * @param   _id     token ID to burn
     * @param   _value  amount of tokens to burn
     *
     * @dev     The standard doesn't explicitly specify burn functions but aludes to them as something necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic shifted to _burn() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _from == address(0).
     * @dev     Emits TransferSingle() event on successful burn.
     */
    function burn(address _from, uint256 _id, uint256 _value) public virtual nonReentrant {
        _burn(_from, _id, _value);
    }

    /**
     * @notice  burnBatch()
     *          Burns `[]_values` amounts of tokens of types `[]_ids` from `_from` address.
     * @param   _from   source aka owner address to burn from
     * @param   _ids    array of token IDs to burn
     * @param   _values array of amounts of tokens to burn
     *
     * @dev     The standard doesn't explicitly specify burn functions but aludes to them as something necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic shifted to _burnBatch() to facilitate more flexible overriding.
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if _from == address(0).
     * @dev     Reverts if _ids.length != _values.length.
     * @dev     Emits TransferBatch() event if every token burn is successful.
     */
    function burnBatch(
        address _from, uint256[] calldata _ids, uint256[] calldata _values
        ) public virtual nonReentrant {
        _burnBatch(_from, _ids, _values);
    }

    /**
     * @notice  broadcastToken()
     *          Broadcasts the existence of a token of type `_id` and its creator.
     * @param   _tokenCreator   creator of the token
     * @param   _id             token ID to broadcast
     *
     * @dev     The standard doesn't explicitly specify this function but mentions the event emission as something
     *          the contract should do to broadcast the existence of a token with no initial balance.
     */
    function broadcastToken(address _tokenCreator, uint256 _id) public virtual {
        emit TransferSingle(_tokenCreator, address(0), address(0), _id, 0);
    }

    /**
     * @notice  balanceOf()
     *          Returns the amount of tokens of type `_id` owned by `_owner` address.
     * @param   _owner  owner address to query
     * @param   _id     token ID to query
     *
     * @dev     Getter function that should never revert. But what if _owner == address(0)?
     *          ANSWER: just return 0.
     *          Because such a call has no negative impact on the state of the contract, so no need to revert.
     *          Means that the implementation code has to ensure that balance of address(0) is permanently and unchangably
     *          fixed to 0 at all times.
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
     *          ANSWER: just return 0 balance for the zero address owner.
     *          Because such a call has no negative impact on the state of the contract, so no need to revert.
     *          Means that the implementation code has to ensure that balance of address(0) is permanently and unchangably
     *          fixed to 0 at all times.
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
     *
     * @dev     Is nonReentrant modifier needed here?
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
        // return false if owner or operator == address(0)
        if ((_owner == address(0)) || (_operator == address(0))) {
            return false;
        }
        return _operatorApprovals[_owner][_operator];
    }

    // internal and utility functions /////////////////////////////////////////////////////
    /**
     * @notice  _safeTransferFrom()
     *          Contains the logic of safeTransferFrom().
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to transfer
     * @param   _data   optional data
     */
    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) internal virtual {
        if (_from == address(0)) {
            revert("ERC1155: transfer from address(0)");
        }
        if ((msg.sender != _from) && (!isApprovedForAll(_from, msg.sender))) {
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
     *          Contains the logic of safeBatchTransferFrom().
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _ids    array of token IDs to transfer
     * @param   _values array of amounts of each token to transfer
     * @param   _data   optional data
     */
    function _safeBatchTransferFrom(
        address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data
        ) internal virtual {
        if (_from == address(0)) {
            revert("ERC1155: transfer from address(0)");
        }
        if ((msg.sender != _from) && (!isApprovedForAll(_from, msg.sender))) {
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
     * @notice  _mint()
     *          Contains the logic of mint().
     * @param   _to     receiver address to mint to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to mint
     * @param   _data   optional data
     */
    function _mint(address _to, uint256 _id, uint256 _value, bytes calldata _data) internal virtual {
        if (_to == address(0)) {
            revert("ERC1155: mint to address(0)");
        }
        // perform mint
        _updateBalances(address(0), _to, _id, _value);
        // emit TransferSingle
        emit TransferSingle(msg.sender, address(0), _to, _id, _value);
        // check if recipient is a contract
        if (isContract(_to)) {
            // call onERC1155Received() and check return value
            if (IERC1155TokenReceiver(_to).onERC1155Received(address(0), _to, _id, _value, _data) != ERC1155_SINGLE_TRANSFER_ACCEPTED) {
                revert("ERC1155: mint not accepted by receiver contract");
            }
        }
    }

    /**
     * @notice  _mintBatch()
     *          Contains the logic of mintBatch().
     * @param   _to     receiver address to mint to
     * @param   _ids    array of token IDs to mint
     * @param   _values array of amounts of each token to mint
     * @param   _data   optional data
     */
    function _mintBatch(address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) internal virtual {
        if (_to == address(0)) {
            revert("ERC1155: mint to address(0)");
        }
        if (_ids.length != _values.length) {
            revert("ERC1155: ids and values array lengths mismatch");
        }
        // perform mint
        for (uint256 i = 0; i < _ids.length; i++) {
            _updateBalances(address(0), _to, _ids[i], _values[i]);
        }
        // emit TransferBatch
        emit TransferBatch(msg.sender, address(0), _to, _ids, _values);
        // check if recipient is a contract
        if (isContract(_to)) {
            // call onERC1155BatchReceived() and check return value
            if (IERC1155TokenReceiver(_to).onERC1155BatchReceived(address(0), _to, _ids, _values, _data) != ERC1155_BATCH_TRANSFER_ACCEPTED) {
                revert("ERC1155: batch mint not accepted by receiver contract");
            }
        }
    }

    /**
     * @notice  _burn()
     *          Contains the logic of burn().
     * @param   _from   sender address to burn from
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to burn
     */
    function _burn(address _from, uint256 _id, uint256 _value) internal virtual {
        if (_from == address(0)) {
            revert("ERC1155: burn from address(0)");
        }
        // perform burn
        _updateBalances(_from, address(0), _id, _value);
        // emit TransferSingle
        emit TransferSingle(msg.sender, _from, address(0), _id, _value);
    }

    /**
     * @notice  _burnBatch()
     *          Contains the logic of burnBatch().
     * @param   _from   sender address to burn from
     * @param   _ids    array of token IDs to burn
     * @param   _values array of amounts of each token to burn
     */
    function _burnBatch(address _from, uint256[] calldata _ids, uint256[] calldata _values) internal virtual {
        if (_from == address(0)) {
            revert("ERC1155: burn from address(0)");
        }
        if (_ids.length != _values.length) {
            revert("ERC1155: ids and values array lengths mismatch");
        }
        // perform burn
        for (uint256 i = 0; i < _ids.length; i++) {
            _updateBalances(_from, address(0), _ids[i], _values[i]);
        }
        // emit TransferBatch
        emit TransferBatch(msg.sender, _from, address(0), _ids, _values);
    }

    /**
     * @notice  _updateBalances()
     *          Updates the owner and receiver token balances.
     * @param   _from   owner address aka source address tokens are sent from
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
     * @dev     Reverts on arithmetic overflow/underflow when calculating balances.
     */
    function _updateBalances(address _from, address _to, uint256 _id, uint256 _value) internal virtual {
        if ((_from == address(0)) && (_to != address(0))) {
            // minting
            _balances[_to][_id] += _value;
        } else if ((_from != address(0)) && (_to == address(0))) {
            // burning
            if (_value > balanceOf(_from, _id)) {
                revert("ERC1155: burn amount exceeds balance");
            }
            _balances[_from][_id] -= _value;
        } else if ((_from != address(0)) && (_to != address(0))) {
            // transfer
            if (_value > balanceOf(_from, _id)) {
                revert("ERC1155: transfer amount exceeds sender balance");
            }
            _balances[_from][_id] -= _value;
            _balances[_to][_id] += _value;
        }
    }

    /**
     * @notice  _updateApprovals()
     *          Contains the logic of setApprovalForAll().
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