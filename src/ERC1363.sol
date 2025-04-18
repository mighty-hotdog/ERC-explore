// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";
import {ERC165} from "./ERC165.sol";
import {IERC1363} from "./IERC1363.sol";
import {IERC1363Receiver} from "./IERC1363Receiver.sol";
import {IERC1363Spender} from "./IERC1363Spender.sol";

/**
 * @title   ERC1363
 *          An implementation of the ERC1363 standard https://eips.ethereum.org/EIPS/eip-1363.
 * @author  @mighty_hotdog
 *          created 2025-04-17
 *          modified 2025-04-18
 *              added natspecs and code comments
 *              applied ReentrancyGuard to protect against reentrancy and added associated comments to describe it
 *
 * @dev     This contract cannot be used on its own but is intended to be inherited into other contracts.
 *
 * @dev     ReentrancyGuard from OpenZeppelin may not be inherited here again because it has already been inherited in
 *          ERC20Core. It may however still be used here to protect against reentrancy.
 * @dev     ReentrancyGuard is applied here for functions that change state and subsequently perform external calls:
 *              _transferAndCall(), _transferFromAndCall(), _approveAndCall().
 */
abstract contract ERC1363 is IERC1363, ERC20Core, ERC165 {
    // constants //////////////////////////////////////////////////////////////////////////
    // interface IDs to be added by default to ERC165 supported list
    bytes4 public constant ERC1363_INTERFACE_ID = 0xb0202a11;
    bytes4 public constant ERC20Core_INTERFACE_ID = 
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
        bytes4(keccak256("transferFrom(address,address,uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("allowance(address,address)"));
    
    // ERC1363 receiver return values indicating transfer accepted
    bytes4 public constant ERC1363_TRANSFER_ACCEPTED = 
        bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));

    // ERC1363 spender return values indicating approval accepted
    bytes4 public constant ERC1363_APPROVAL_ACCEPTED = 
        bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"));

    // functions //////////////////////////////////////////////////////////////////////////
    /**
     * @notice  constructor()
     * @param   interfaceIds    array of supported interfaces
     *
     * @dev     No need to include ERC1363 and ERC20Core interfaces in input array.
     *          Constructor adds them by default.
     */
    constructor(bytes4[] memory interfaceIds) ERC165(interfaceIds) {
        super._addSupportedInterface(ERC1363_INTERFACE_ID);
        super._addSupportedInterface(ERC20Core_INTERFACE_ID);
    }

    /**
     * @notice  transferAndCall()
     *          Transfers tokens from msg.sender to recipient.
     *          Calls `onTransferReceived()` on recipient if it is a contract.
     *          Fires a Transfer event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   to      recipient address to transfer to
     * @param   value   amount of tokens to transfer
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender
     * @dev     recipient can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if to == address(0)
     * @dev     reverts if caller balance < value
     * @dev     value == 0 allowed and valid
     * @dev     reverts if `onTransferReceived()` call on recipient reverts
     * @dev     reverts if `onTransferReceived()` call on recipient returns value != ERC1363_TRANSFER_ACCEPTED
     *
     * @dev     Logic shifted to _transferAndCall() to facilitate more flexible overriding.
     */
    function transferAndCall(address to, uint256 value) public virtual returns (bool) {
        return _transferAndCall(to, value, "", true);
    }

    /**
     * @notice  transferAndCall()
     *          Transfers tokens from msg.sender to recipient.
     *          Calls `onTransferReceived()` on recipient with `data` if it is a contract.
     *          Fires a Transfer event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   to      recipient address to transfer to
     * @param   value   amount of tokens to transfer
     * @param   data    additional data with no specified format, sent in `onTransferReceived()` call to recipient
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender
     * @dev     recipient can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if to == address(0)
     * @dev     reverts if caller balance < value
     * @dev     value == 0 allowed and valid
     * @dev     reverts if `onTransferReceived()` call on recipient reverts
     * @dev     reverts if `onTransferReceived()` call on recipient returns value != ERC1363_TRANSFER_ACCEPTED
     *
     * @dev     Logic shifted to _transferAndCall() to facilitate more flexible overriding.
     */
    function transferAndCall(address to, uint256 value, bytes memory data) public virtual returns (bool) {
        return _transferAndCall(to, value, data, true);
    }

    /**
     * @notice  transferFromAndCall()
     *          Transfers tokens from source to recipient.
     *          Calls `onTransferReceived()` on recipient if it is a contract.
     *          Fires a Transfer event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   from    source address to transfer from
     * @param   to      recipient address to transfer to
     * @param   value   amount of tokens to transfer
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender == spender
     * @dev     source and recipient can be each be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if from == address(0)
     * @dev     reverts if to == address(0)
     * @dev     reverts if spender allowance < value
     * @dev     reverts if source balance < value
     * @dev     value == 0 allowed and valid
     * @dev     reverts if `onTransferReceived()` call on recipient reverts
     * @dev     reverts if `onTransferReceived()` call on recipient returns value != ERC1363_TRANSFER_ACCEPTED
     *
     * @dev     Logic shifted to _transferFromAndCall() to facilitate more flexible overriding.
     */
    function transferFromAndCall(address from, address to, uint256 value) public virtual returns (bool) {
        return _transferFromAndCall(from, to, value, "", true);
    }

    /**
     * @notice  transferFromAndCall()
     *          Transfers tokens from source to recipient.
     *          Calls `onTransferReceived()` on recipient with `data` if it is a contract.
     *          Fires a Transfer event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   from    source address to transfer from
     * @param   to      recipient address to transfer to
     * @param   value   amount of tokens to transfer
     * @param   data    additional data with no specified format, sent in `onTransferReceived()` call to recipient
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender == spender
     * @dev     source and recipient can be each be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if from == address(0)
     * @dev     reverts if to == address(0)
     * @dev     reverts if spender allowance < value
     * @dev     reverts if source balance < value
     * @dev     value == 0 allowed and valid
     * @dev     reverts if `onTransferReceived()` call on recipient reverts
     * @dev     reverts if `onTransferReceived()` call on recipient returns value != ERC1363_TRANSFER_ACCEPTED
     *
     * @dev     Logic shifted to _transferFromAndCall() to facilitate more flexible overriding.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) public virtual returns (bool) {
        return _transferFromAndCall(from, to, value, data, true);
    }

    /**
     * @notice  approveAndCall()
     *          Grants approval to spender to spend tokens from caller balance.
     *          Calls `onApprovalReceived()` on spender if it is a contract.
     *          Fires an Approval event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   spender spender address to grant allowance to
     * @param   value   allowance, ie: amount of tokens spender is allowed to spend from caller's balance
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender
     * @dev     spender can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if spender == address(0)
     * @dev     reverts if `onApprovalReceived()` call on spender reverts
     * @dev     reverts if `onApprovalReceived()` call on spender returns value != ERC1363_APPROVAL_ACCEPTED
     *
     * @dev     Logic shifted to _approveAndCall() to facilitate more flexible overriding.
     */
    function approveAndCall(address spender, uint256 value) public virtual returns (bool) {
        return _approveAndCall(spender, value, "", true);
    }

    /**
     * @notice  approveAndCall()
     *          Grants approval to spender to spend tokens from caller balance.
     *          Calls `onApprovalReceived()` on spender with `data` if it is a contract.
     *          Fires an Approval event. This is not specified in the ERC1363 standard and is specific to this implementation.
     * @param   spender spender address to grant allowance to
     * @param   value   allowance, ie: amount of tokens spender is allowed to spend from caller's balance
     * @param   data    additional data with no specified format, sent in `onApprovalReceived()` call to spender
     * @dev     returns true unless reverted
     *
     * @dev     caller == msg.sender
     * @dev     spender can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if spender == address(0)
     * @dev     reverts if `onApprovalReceived()` call on spender reverts
     * @dev     reverts if `onApprovalReceived()` call on spender returns value != ERC1363_APPROVAL_ACCEPTED
     *
     * @dev     Logic shifted to _approveAndCall() to facilitate more flexible overriding.
     */
    function approveAndCall(address spender, uint256 value, bytes memory data) public virtual returns (bool) {
        return _approveAndCall(spender, value, data, true);
    }

    // internal and utility functions //////////////////////////////////////////////////////
    /**
     * @notice  _transferAndCall()
     *          Contains logic for both transferAndCall() functions.
     * @param   to          recipient address to transfer to
     * @param   value       amount of tokens to transfer
     * @param   data        additional data with no specified format, sent in `onTransferReceived()` call to recipient
     * @param   emitEvent   whether to emit Transfer event
     * @dev     returns true unless reverted
     */
    function _transferAndCall(
        address to, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual nonReentrant returns (bool) {
        super.transfer(to, value);
        if (emitEvent) {
            emit Transfer(msg.sender, to, value, data);
        }
        if (isContract(to)) {
            if (IERC1363Receiver(to).onTransferReceived(address(this), msg.sender, value, data) != ERC1363_TRANSFER_ACCEPTED) {
                revert("ERC1363: transfer not accepted by receiver contract");
            }
        }
        return true;
    }

    /**
     * @notice  _transferFromAndCall()
     *          Contains logic for both transferFromAndCall() functions.
     * @param   from        source address to transfer from
     * @param   to          recipient address to transfer to
     * @param   value       amount of tokens to transfer
     * @param   data        additional data with no specified format, sent in `onTransferReceived()` call to recipient
     * @param   emitEvent   whether to emit Transfer event
     * @dev     returns true unless reverted
     */
    function _transferFromAndCall(
        address from, address to, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual nonReentrant returns (bool) {
        super.transferFrom(from, to, value);
        if (emitEvent) {
            emit Transfer(from, to, value, data);
        }
        if (isContract(to)) {
            if (IERC1363Receiver(to).onTransferReceived(address(this), from, value, data) != ERC1363_TRANSFER_ACCEPTED) {
                revert("ERC1363: transfer not accepted by receiver contract");
            }
        }
        return true;
    }

    /**
     * @notice  _approveAndCall()
     *          Contains logic for both approveAndCall() functions.
     * @param   spender     spender address to grant allowance to
     * @param   value       allowance, ie: amount of tokens spender is allowed to spend from caller's balance
     * @param   data        additional data with no specified format, sent in `onTransferReceived()` call to recipient
     * @param   emitEvent   whether to emit Transfer event
     * @dev     returns true unless reverted
     */
    function _approveAndCall(
        address spender, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual nonReentrant returns (bool) {
        super.approve(spender, value);
        if (emitEvent) {
            emit Approval(msg.sender, spender, value, data);
        }
        if (isContract(spender)) {
            if (IERC1363Spender(spender).onApprovalReceived(address(this), value, data) != ERC1363_APPROVAL_ACCEPTED) {
                revert("ERC1363: approval not accepted by spender contract");
            }
        }
        return true;
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