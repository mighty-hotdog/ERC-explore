// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// these imports are just for reference, not used in the contract
//import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC165} from "forge-std/interfaces/IERC165.sol";
import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

// these imports are used in the contract
import {ERC20Core} from "./ERC20Core.sol";
import {ERC20Metadata} from "./ERC20Metadata.sol";
import {ERC20Mintable} from "./ERC20Mintable.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {Pausable} from "./Pausable.sol";
import {Ownable} from "./Ownable.sol";
import {ERC2612} from "./ERC2612.sol";
import {ERC677} from "./ERC677.sol";
import {ERC165} from "./ERC165.sol";

/**
 * @title   ERC20SampleCustomToken
 *          A sample contract for a custom ERC20 token.
 * @author  @mighty_hotdog
 *          created 2025-03-10
 *          modified 2025-03-11
 *              to add capping functionality with new ERC20Mintable
 *              to add pausing functionality with ERC20Pausable
 *              to add ownership functionality with ERC20Ownable
 *          modified 2025-03-13
 *              to add ERC2612 functionality
 *          modified 2025-03-14
 *              to add ERC677 functionality
 *              to add ERC165 functionality
 */
contract ERC20SampleCustomToken is ERC20Core, ERC20Metadata, ERC20Mintable, ERC20Burnable, Pausable, Ownable, ERC2612, ERC677, ERC165 {
    // events
    event SCT_Minted(address indexed toAccount, uint256 amount);
    event SCT_Burned(address indexed fromAccount, uint256 amount);

    // constants
    uint256 public constant MAX_TOKEN_SUPPLY = type(uint256).max;
    uint256 public constant STARTING_TOTAL_SUPPLY = 1e9; // 1 billion tokens
    uint8 public constant DECIMALS = 8;

    // functions
    constructor(address initialOwner, bytes4[] memory supportedInterfaceIds) 
            ERC20Mintable(MAX_TOKEN_SUPPLY) 
            ERC20Metadata("SampleCustomToken", "SCT") 
            Ownable(initialOwner) 
            ERC165(supportedInterfaceIds) {
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
        burnFrom(_from, _value);
        emit SCT_Burned(_from, _value);
        return true;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}
