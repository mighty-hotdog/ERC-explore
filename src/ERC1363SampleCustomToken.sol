// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1363} from "./ERC1363.sol";
import {ERC20Metadata} from "./ERC20Metadata.sol";
import {ERC20Mintable} from "./ERC20Mintable.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {Pausable} from "./Pausable.sol";
import {Ownable} from "./Ownable.sol";

contract ERC1363SampleCustomToken is ERC1363, ERC20Metadata, ERC20Mintable, ERC20Burnable, Pausable, Ownable {
    // events ///////////////////////////////////////////////////////////
    event SCT_Minted(address indexed toAccount, uint256 amount);
    event SCT_Burned(address indexed fromAccount, uint256 amount);

    // constants ////////////////////////////////////////////////////////
    // token constants
    uint256 public constant MAX_TOKEN_SUPPLY = type(uint256).max;
    uint256 public constant STARTING_TOTAL_SUPPLY = 1e9; // 1 billion tokens
    uint8 public constant DECIMALS = 8;

    // interface ids to be added by default to ERC165 supported list
    bytes4 public constant ERC20Metadata_INTERFACE_ID = 
        bytes4(keccak256("name()")) ^ 
        bytes4(keccak256("symbol()")) ^ 
        bytes4(keccak256("decimals()"));

    // functions ////////////////////////////////////////////////////////
    constructor(address initialOwner, bytes4[] memory supportedInterfaceIds) 
            ERC1363(supportedInterfaceIds)
            ERC20Mintable(MAX_TOKEN_SUPPLY) 
            ERC20Metadata("SampleCustomToken", "SCT") 
            Ownable(initialOwner) {
        super._addSupportedInterface(ERC20Metadata_INTERFACE_ID);
        mint(msg.sender, STARTING_TOTAL_SUPPLY);
    }

    function mint(address _to, uint256 _value) public override pausable onlyOwner returns (bool) {
        super.mint(_to, _value);
        emit SCT_Minted(_to, _value);
        return true;
    }

    function burn(uint256 _value) public override pausable returns (bool) {
        super.burn(_value);
        emit SCT_Burned(msg.sender, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public pausable returns (bool) {
        super.burnFrom(_from, _value);
        emit SCT_Burned(_from, _value);
        return true;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}