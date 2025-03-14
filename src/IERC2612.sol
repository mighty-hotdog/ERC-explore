// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC2612
 *          Interface for ERC2612 compatible tokens. https://eips.ethereum.org/EIPS/eip-2612
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC2612 {
    /**
     * @notice  permit()
     *          Verifies the signature and then updates the allowance of the spender for the owner.
     * @param   owner       address of the owner
     * @param   spender     address of the spender
     * @param   value       allowance to be granted to the spender
     * @param   deadline    deadline for the signature
     * @param   v           v component of the signature
     * @param   r           r component of the signature
     * @param   s           s component of the signature
     */
    function permit(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external;

    /**
     * @notice  nonces()
     *          Returns the current available nonce for the owner address.
     * @param   owner   address of the owner
     * @dev     A getter function that never reverts.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @notice  DOMAIN_SEPARATOR()
     *          Returns the domain separator for this contract.
     * @dev     A getter function that never reverts.
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}