// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC677Receiver
 *          Interface for contracts that want to receive ERC677 tokens. https://github.com/ethereum/EIPs/issues/677
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC677Receiver {
    /**
     * @notice  onTokenTransfer()
     *          (Intended to be) called by the ERC677 token contract from inside its transferAndCall() function.
     * @param   from    (intended to be) address of the tokens sender, who called the transferAndCall() function
     * @param   value   (intended to be) amount of tokens transferred by the sender
     * @param   data    additional data
     *
     * @dev     Developers should note that while the ERC677 specification has its design intent, hackers may
     *          try to exploit it in unintended and unexpected ways.
     *          eg: calling onTokenTransfer() from outside transferAndCall(), calling onTokenTransfer() from another contract,
     *              calling onTokenTransfer() with different parameters, etc.
     */
    function onTokenTransfer(address from, uint256 value, bytes memory data) external returns (bool);
}