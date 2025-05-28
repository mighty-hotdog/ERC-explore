// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC6909Core} from "./IERC6909Core.sol";
import {ERC165} from "./ERC165.sol";

/**
 * @title   ERC6909Core
 *          An implementation of the core ERC6909 standard. https://eips.ethereum.org/EIPS/eip-6909
 * @author  @mighty_hotdog
 *          created 2025-05-23
 *          modified 2025-05-28
 *              added new check for (_from != msg.sender) in _transferFrom()
 *              added new tokenSupply() function that replaces the Token Supply extension
 *
 * @dev     Questions that MUST be answered for this contract to even be barebones useful:
 *          1. How to launch a new token under this contract?
 *          2. How to delist/remove an existing token?
 *          3. How to pause/unpause, suspend/resume a token?
 *          4. How to assign ownership and/or manage access control for a token?
 *          5. How to manage token supply?
 *          6. How to migrate non-native tokens (eg: BTC, ETH, etc) to/from this contract?
 *          7. How to integrate vaults?
 *          8. What are the invariants here?
 */
abstract contract ERC6909Core is IERC6909Core, ERC165 {
    // constants //////////////////////////////////////////////////////////////////////////
    bytes4 public constant ERC6909_CORE_INTERFACE_ID = 0x0f632fb3;

    // state variables ////////////////////////////////////////////////////////////////////
    mapping(uint256 id => uint256 totalSupply) private _totalSupplies;
    mapping(address owner => mapping(uint256 id => uint256 amount)) private _balances;
    mapping(address owner => mapping(address spender => bool approved)) private _operators;
    mapping(address owner => mapping(address spender => mapping(uint256 id => uint256 amount))) private _allowances;

    // functions //////////////////////////////////////////////////////////////////////////
    /**
     * @notice  constructor()
     * @param   supportedInterfaces array of supported interfaces
     */
    constructor(bytes4[] memory supportedInterfaces) ERC165(supportedInterfaces) {
        _onCreation();
    }

    /**
     * @notice  balanceOf()
     *          Returns balance of an account.
     * @param   owner   address of owner
     * @param   id      token ID
     *
     * @dev     View function. Never reverts.
     */
    function balanceOf(address owner, uint256 id) public view virtual returns (uint256 amount) {
        return _balances[owner][id];
    }

    /**
     * @notice  allowance()
     *          Returns allowance of an account.
     * @param   owner   address of owner
     * @param   spender address of spender
     * @param   id      token ID
     *
     * @dev     View function. Never reverts.
     */
    function allowance(address owner, address spender, uint256 id) public view virtual returns (uint256 amount) {
        return _allowances[owner][spender][id];
    }

    /**
     * @notice  isOperator()
     *          Returns status of an operator.
     * @param   owner   address of owner
     * @param   spender address of spender
     * @return  status  true == spender is an approved operator for owner, false == spender is not approved
     *
     * @dev     View function. Never reverts.
     */
    function isOperator(address owner, address spender) public view virtual returns (bool status) {
        return _operators[owner][spender];
    }

    /**
     * @notice  transfer()
     *          Transfers tokens from one account to another.
     * @param   receiver    address of receiver
     * @param   id          token ID
     * @param   amount      amount of tokens to transfer
     *
     * @dev     Caller == msg.sender == address of owner from which tokens are to be transferred.
     * @dev     Nonpayable function.
     * @dev     Reverts if:
     *          - receiver == address(0)
     *          - amount > owner balance
     * @dev     Updates owner and receiver token balances.
     * @dev     Emits Transfer event.
     *
     * @dev     Logic moved to _transfer() to facilitate more flexible overriding.
     */
    function transfer(address receiver, uint256 id, uint256 amount) public virtual returns (bool success) {
        _transfer(receiver, id, amount);
        return true;
    }

    /**
     * @notice  transferFrom()
     *          Transfers tokens from one account to another.
     * @param   sender      address of owner from which tokens are to be transferred
     * @param   receiver    address of receiver
     * @param   id          token ID
     * @param   amount      amount of tokens to transfer
     *
     * @dev     Caller == msg.sender == address of spender who will transfer the tokens on behalf of the owner.
     * @dev     Nonpayable function.
     * @dev     Reverts if:
     *          - sender == address(0)
     *          - receiver == address(0)
     *          - amount > spender allowance
     *          - amount > sender balance
     * @dev     Updates sender and receiver token balances.
     * @dev     Updates spender allowance.
     * @dev     Emits Transfer event.
     *
     * @dev     Logic moved to _transferFrom() to facilitate more flexible overriding.
     */
    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) public virtual returns (bool success) {
        _transferFrom(sender, receiver, id, amount);
        return true;
    }

    /**
     * @notice  approve()
     *          Lets owner set the allowance of a spender for a particular token on the owner's behalf.
     * @param   spender    address of spender
     * @param   id         token ID
     * @param   amount     allowance
     *
     * @dev     Caller == msg.sender == address of owner who will grant the allowance.
     * @dev     Reverts if:
     *          - spender == address(0)
     * @dev     Updates spender allowance.
     * @dev     Emits Approval event.
     *
     * @dev     Logic moved to _approve() to facilitate more flexible overriding.
     */
    function approve(address spender, uint256 id, uint256 amount) public virtual returns (bool success) {
        _approve(spender, id, amount);
        return true;
    }

    /**
     * @notice  setOperator()
     *          Lets owner grant or revoke operator status to a spender.
     * @param   spender    address of spender
     * @param   approved   true == spender is an approved operator of the owner, false == spender is not an approved operator
     *
     * @dev     Caller == msg.sender == address of owner who will set the operator status.
     * @dev     Reverts if:
     *          - spender == address(0)
     * @dev     Updates operator status.
     * @dev     Emits OperatorSet event.
     *
     * @dev     Logic moved to _setOperator() to facilitate more flexible overriding.
     */
    function setOperator(address spender, bool approved) public virtual returns (bool success) {
        _setOperator(spender, approved);
        return true;
    }

    /**
     * @notice  mint()
     *          Mints tokens.
     * @param   _to     receiver address to mint to
     * @param   _id     token ID
     * @param   _value  amount of tokens to mint
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if:
     *          - _to == address(0)
     *          - _value == 0, to prevent waste of gas on a tx that does nothing
     * @dev     Updates _to token balance.
     * @dev     Emits Transfer() event.
     *
     * @dev     Standard doesn't explicitly specifiy mint functions, but they are obviously necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic moved to _mint() to facilitate more flexible overriding.
     */
    function mint(address _to, uint256 _id, uint256 _value) public virtual returns (bool success) {
        _mint(_to, _id, _value);
        return true;
    }

    /**
     * @notice  burn()
     *          Burns tokens.
     * @param   _from   source address from which to burn tokens
     * @param   _id     token ID
     * @param   _value  amount of tokens to burn
     *
     * @dev     Caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here.
     * @dev     Reverts if:
     *          - _from == address(0)
     *          - _value == 0, to prevent waste of gas on a tx that does nothing
     * @dev     Updates _from token balance.
     * @dev     Emits Transfer() event.
     *
     * @dev     Standard doesn't explicitly specifiy burn functions but they are obviously necessary.
     *          The logic here is specific to this implementation.
     * @dev     Logic moved to _burn() to facilitate more flexible overriding.
     */
    function burn(address _from, uint256 _id, uint256 _value) public virtual returns (bool success) {
        _burn(_from, _id, _value);
        return true;
    }

    /**
     * @notice  tokenSupply()
     *          Returns the total supply of a particular token.
     * @param   _id     token ID
     * @return          total supply
     *
     * @dev     View function. Never reverts.
     * @dev     The ERC6909 standard describes a Token Supply extension that seems to be a result of bad design decisions.
     * @dev     This function duplicates and replaces the Token Supply extension described in the ERC6909 standard.
     */
    function tokenSupply(uint256 _id) public view virtual returns (uint256) {
        return _totalSupplies[_id];
    }

    // internal and utility functions /////////////////////////////////////////////////////
    /**
     * @notice  _onCreation()
     *          Contains the logic of contructor().
     *
     * @dev     Adds the ERC6909 core interface by default to list of supported interfaces.
     *          Override to add additional default interfaces and custom constructor logic.
     */
    function _onCreation() internal virtual {
        super._addSupportedInterface(ERC6909_CORE_INTERFACE_ID);
    }

    /**
     * @notice  _transfer()
     *          Contains the logic of transfer().
     * @param   _to     receiver address to transfer to
     * @param   _id     token ID
     * @param   _value  amount of tokens to transfer
     */
    function _transfer(address _to, uint256 _id, uint256 _value) internal virtual {
        if (_to == address(0)) {
            revert("ERC6909: transfer to address(0)");
        }
        _updateBalance(msg.sender, _to, _id, _value);
    }

    /**
     * @notice  _transferFrom()
     *          Contains the logic of transferFrom().
     * @param   _from   source aka owner address to transfer from
     * @param   _to     receiver address to transfer to
     * @param   _id     token ID, indicating token type
     * @param   _value  amount of tokens to transfer
     */
    function _transferFrom(address _from, address _to, uint256 _id, uint256 _value) internal virtual {
        if (_from == address(0)) {
            revert("ERC6909: transfer from address(0)");
        }
        if (_to == address(0)) {
            revert("ERC6909: transfer to address(0)");
        }
        if ((_from != msg.sender) && (!isOperator(_from, _to))) {
            uint256 currentAllowance = allowance(_from, _to, _id);
            if (_value > currentAllowance) {
                revert("ERC6909: transfer amount exceeds allowance");
            }
            if (!(currentAllowance == type(uint256).max)) {
                _updateAllowance(_from, _to, _id, currentAllowance - _value);
            }
        }
        _updateBalance(_from, _to, _id, _value);
    }

    /**
     * @notice  _approve()
     *          Contains the logic of approve().
     * @param   _spender    receiver address to transfer to
     * @param   _id         token ID
     * @param   _value      amount of tokens to transfer
     */
    function _approve(address _spender, uint256 _id, uint256 _value) internal virtual {
        if (_spender == address(0)) {
            revert("ERC6909: approve to address(0)");
        }
        _updateAllowance(msg.sender, _spender, _id, _value);
        emit Approval(msg.sender, _spender, _id, _value);
    }

    /**
     * @notice  _setOperator()
     *          Contains the logic of setOperator().
     * @param   _spender    receiver address to transfer to
     * @param   _approved   approval status, true == approved, false == not approved
     */
    function _setOperator(address _spender, bool _approved) internal virtual {
        if (_spender == address(0)) {
            revert("ERC6909: set address(0) as operator");
        }
        _operators[msg.sender][_spender] = _approved;
        emit OperatorSet(msg.sender, _spender, _approved);
    }

    /**
     * @notice  _mint()
     *          Contains the logic of mint().
     */
    function _mint(address _to, uint256 _id, uint256 _value) internal virtual {
        if (_to == address(0)) {
            revert("ERC6909: mint to address(0)");
        }
        if (_value == 0) {
            revert("ERC6909: mint amount is zero");
        }
        _updateBalance(address(0), _to, _id, _value);
        emit Transfer(msg.sender, address(0), _to, _id, _value);
    }

    /**
     * @notice  _burn()
     *          Contains the logic of burn().
     */
    function _burn(address _from, uint256 _id, uint256 _value) internal virtual {
        if (_from == address(0)) {
            revert("ERC6909: burn from address(0)");
        }
        if (_value == 0) {
            revert("ERC6909: burn amount is zero");
        }
        _updateBalance(_from, address(0), _id, _value);
        emit Transfer(msg.sender, _from, address(0), _id, _value);
    }

    /**
     * @notice  _updateBalance()
     *          Effects token transfer, mint and burn by updating balance and total supply accordingly.
     * @param   _from   source address from which to transfer tokens
     * @param   _to     destination address to transfer tokens to
     * @param   _id     token ID
     * @param   _value  amount of tokens to transfer
     * @dev     Intended to be the only place that updates balances and total supplies of all tokens in the contract.
     *          As such, its design is solely focused on correctly updating the balances, including all error checks
     *          and logic needed to perform these operations correctly.
     *          eg: balance < _value, overflow/underflow
     */
    function _updateBalance(address _from, address _to, uint256 _id, uint256 _value) internal virtual {
        if (_from == address(0) && _to != address(0)) {
            // minting
            if (type(uint256).max - _balances[_to][_id] < _value) {
                revert("ERC6909: balance overflow");
            }
            if (type(uint256).max - _totalSupplies[_id] < _value) {
                revert("ERC6909: total supply overflow");
            }
            _balances[_to][_id] += _value;
            _totalSupplies[_id] += _value;
        } else if (_from != address(0) && _to == address(0)) {
            // burning
            if (_value > balanceOf(_from, _id)) {
                revert("ERC6909: burn amount exceeds balance");
            }
            _balances[_from][_id] -= _value;
            _totalSupplies[_id] -= _value;
        } else if (_from != address(0) && _to != address(0)) {
            // transfer
            if (_value > balanceOf(_from, _id)) {
                revert("ERC6909: transfer amount exceeds sender balance");
            }
            _balances[_from][_id] -= _value;
            _balances[_to][_id] += _value;
        }
        emit Transfer(msg.sender, _from, _to, _id, _value);
    }

    /**
     * @notice  _updateAllowance()
     *          Updates allowance when spending occurs, or when owner sets a new value.
     * @dev     Intended to be the only place that updates allowances of all spenders for all tokens in the contract.
     */
    function _updateAllowance(address owner, address spender, uint256 id, uint256 value) internal virtual {
        _allowances[owner][spender][id] = value;
    }
}