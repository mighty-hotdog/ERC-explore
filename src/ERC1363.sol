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
 * @author  @mighty_hotdog 2025-04-17
 *
 * @dev     Outstanding TODOs:
 *          1. Complete the natspec and code comments
 *          2. Create a sample ERC1363 token contract
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
    constructor(bytes4[] memory interfaceIds) ERC165(interfaceIds) {
        super._addSupportedInterface(ERC1363_INTERFACE_ID);
        super._addSupportedInterface(ERC20Core_INTERFACE_ID);
    }

    function transferAndCall(address to, uint256 value) public virtual returns (bool) {
        return _transferAndCall(to, value, "", true);
    }
    function transferAndCall(address to, uint256 value, bytes memory data) public virtual returns (bool) {
        return _transferAndCall(to, value, data, true);
    }
    function transferFromAndCall(address from, address to, uint256 value) public virtual returns (bool) {
        return _transferFromAndCall(from, to, value, "", true);
    }
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) public virtual returns (bool) {
        return _transferFromAndCall(from, to, value, data, true);
    }
    function approveAndCall(address spender, uint256 value) public virtual returns (bool) {
        return _approveAndCall(spender, value, "", true);
    }
    function approveAndCall(address spender, uint256 value, bytes memory data) public virtual returns (bool) {
        return _approveAndCall(spender, value, data, true);
    }

    // internal and utility functions //////////////////////////////////////////////////////
    function _transferAndCall(
        address to, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual returns (bool) {
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
    function _transferFromAndCall(
        address from, address to, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual returns (bool) {
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
    function _approveAndCall(
        address spender, uint256 value, bytes memory data, bool emitEvent
        ) internal virtual returns (bool) {
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