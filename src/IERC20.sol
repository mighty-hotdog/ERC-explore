// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   IERC20
 *          Interface for ERC20 tokens. https://eips.ethereum.org/EIPS/eip-20
 * @author  @mighty_hotdog 2025-03-14
 */
interface IERC20 {
    // events /////////////////////////////////////////////////////////////////////
    /**
     * @notice  Transfer()
     *          Emitted when tokens are transferred, including zero value transfers.
     * @dev     Also triggered in token creation aka minting, ie: _from == address(0).
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * @notice  Approval()
     *          Emitted on successful call to approve() function.
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // functions //////////////////////////////////////////////////////////////////
    /**
     * @notice  totalSupply()
     *          Returns the total token supply.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice  balanceOf()
     *          Returns the balance of an account.
     * @param   _owner  address of the account
     */
    function balanceOf(address _owner) external view returns (uint256 balance);

    /**
     * @notice  transfer()
     *          Transfers tokens from caller to a recipient address and fires Transfer event.
     * @param   _to     recipient address to transfer to
     * @param   _value  amount of tokens to transfer
     */
    function transfer(address _to, uint256 _value) external returns (bool);

    /**
     * @notice  transferFrom()
     *          Transfers tokens from source address to recipient address and fires Transfer event.
     * @param   _from   source address to transfer from
     * @param   _to     recipient address to transfer to
     * @param   _value  amount of tokens to transfer
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    /**
     * @notice  approve()
     *          Grants approval to spender to spend tokens from caller balance and fires Approval event.
     * @param   _spender    spender address
     * @param   _value      allowance, ie: amount of tokens spender is allowed to spend from caller's balance
     */
    function approve(address _spender, uint256 _value) external returns (bool);

    /**
     * @notice  allowance()
     *          Returns remaining allowance spender is still allowed to spend from owner's balance.
     * @param   _owner      owner address
     * @param   _spender    spender address
     */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}