// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC20Metadata
 *          Interface for the optional metadata part of the ERC20 standard. https://eips.ethereum.org/EIPS/eip-20
 * @author  @mighty_hotdog 2025-03-15
 * @dev     Although not explicitly specified in the standard itself, none of these functions should ever revert.
 */
interface IERC20Metadata {
    /**
     * @notice  name()
     *          Returns the name of the token, as set in the constructor.
     * @dev     Essentially a getter function, hence never reverts.
     */
    function name() external view returns (string memory);

    /**
     * @notice  symbol()
     *          Returns the symbol of the token, as set in the constructor.
     * @dev     Essentially a getter function, hence never reverts.
     */
    function symbol() external view returns (string memory);

    /**
     * @notice  decimals()
     *          Returns the decimals of the token.
     * @dev     Purely a cosmetic value for user representation and display purposes. Has zero impact
     *          on any calculation.
     *
     *          For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed
     *          to a user as `5.05` (`505 / 10 ** 2`).
     *          Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei.
     *
     * @dev     This implementation defaults to 18, but can be overridden to return a different value.
     * @dev     Essentially a getter function, hence never reverts.
     */
    function decimals() external view returns (uint8);
}