// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";
import {IERC677} from "./IERC677.sol";
import {IERC677Receiver} from "./IERC677Receiver.sol";

/**
 * @title   ERC677
 *          An implementation of the ERC677 standard https://github.com/ethereum/EIPs/issues/677.
 * @author  @mighty_hotdog
 *          created 2025-03-14
 *          modified 2025-04-16
 *              _transferAndCall() modified to return boolean indicating success or failure
 *              transferAndCall() modified to return result of _transferAndCall()
 * @dev     This contract cannot be used on its own but is intended to be inherited into other contracts.
 */
abstract contract ERC677 is IERC677, ERC20Core {
    /**
     * @notice  transferAndCall()
     *          Moves an amount of tokens from the caller's account to recipient,
     *          then calls onTokenTransfer() on recipient if it is a contract.
     * @param   to      address to transfer to
     * @param   value   amount of tokens to be transferred
     * @param   data    additional data with no specified format, sent in onTokenTransfer() call to `to`
     *
     * @dev     returns true indicating success and false indicating failure
     * @dev     caller == msg.sender
     * @dev     reverts if to == address(0)
     * @dev     if recipient is a contract, calls onTokenTransfer() on it
     *          reverts if onTokenTransfer() not implemented
     * @dev     Logic shifted to _transferAndCall() to facilitate more flexible overidding.
     */
    function transferAndCall(address to, uint256 value, bytes memory data) public virtual returns (bool) {
        return _transferAndCall(to, value, data, true);
    }

    /**
     * @notice  _transferAndCall()
     *          Contains logic for transferAndCall().
     * @param   to          address to transfer to
     * @param   value       amount of tokens to be transferred
     * @param   data        additional data with no specified format, sent in onTokenTransfer() call to `to`
     * @param   emitEvent   whether to emit Transfer() event
     *
     * @dev     returns true indicating success and false indicating failure
     */
    function _transferAndCall(address to, uint256 value, bytes memory data, bool emitEvent) internal virtual returns (bool) {
        // the return value here is ignored because the ERC20Core implementation of this transfer() function reverts on any
        //  failure and always returns true
        super.transfer(to, value);
        if (emitEvent) {
            emit Transfer(msg.sender, to, value, data);
        }
        if (isContract(to)) {
            return IERC677Receiver(to).onTokenTransfer(msg.sender, value, data);
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