// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC677
 *          Interface for ERC677 tokens. https://github.com/ethereum/EIPs/issues/677
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC677 {
    // Emitted upon successful transfer of tokens within the transferAndCall() function.
    event Transfer(address from, address to, uint256 value, bytes data);

    /**
     * @notice  transferAndCall()
     *          Moves an amount of tokens from the caller's account to recipient,
     *          then calls onTokenTransfer() on recipient if it is a contract.
     * @param   to      address to transfer to
     * @param   value   amount of tokens to be transferred
     * @param   data    additional data with no specified format, sent in onTokenTransfer() call to `to`
     * @dev     caller == msg.sender
     * @dev     reverts if to == address(0)
     */
    function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);
}