# ERC4626 - ERC20 Tokenized Vaults

## Important Terms
- **assets**  
	Underlying tokens managed by the Vault.  
    ERC20 token.  

- **shares**  
	Vault tokens representing shares on the assets held in the Vault.  
    ERC20 token.  
	Conversion rate between assets and shares exists that changes according to Vault rules and ongoing conditions.  

- **fees**  
	Amount of assets or shares charged to user by the Vault.  
	Prescribed by Vault rules.  
	Can be for anything, ie: fees can be charged for deposits, yields, AUM, etc.  

- **slippage**  
	Any difference between advertised and actual exchange rate between assets and shares.  
	Excludes fees.  

## convertToShares and convertToAssets
These 2 functions show conversions between assets and shares under "ideal conditions",  
ie: no slippage, no fees, no global restrictions, no user limitations.  

No revert except for arithmetic overflow.  

## deposit and mint
Both groups of functions involve:  
1. caller depositing assets from self into the Vault, and  
2. minting shares to receiver.  

Deposit focuses on asset deposit amount,  
ie: given asset deposit amount, how many shares are minted.  

Mint focuses on share mint amount,  
ie: given share mint amount, how many assets are deposited.  

The caller is the account from which assets are taken and deposited into the Vault.  
The receiver is the account to which shares are minted.  

`deposit()` and `mint()`, the 2 functions that perform the actual depositing/minting, both emit the `Deposit()` event.  

## withdraw and redeem
Both groups of functions involve:  
1. caller burning shares from owner, and  
2. withdrawing assets to receiver.  

Withdraw focuses on asset withdraw amount,  
ie: given asset withdraw amount, how many shares are burned.  

Redeem focuses on share burn amount,  
ie: given share burn amount, how many assets are withdrawn.  

The owner is the account from which shares are burned.  
The receiver is the account to which assets are withdrawn from the Vault.  

`withdraw()` and `redeem()`, the 2 functions that perform the actual withdrawing/redeeming, both emit the `Withdraw()` event.  

## Implementation Considerations
1. Implementions serving EOAs directly should add additional EOA-targetted functions for each of these functions `deposit()`, `mint()`, `withdraw()`, `redeem()` to handle slippage loss or unexpected deposit/withdrawal limits, as there is no other way to revert these transactions if the exact output amount is not achieved.  
2. The convert and preview functions should not be used as price oracles, as their specifications are not intended to produce price-oracle-worthy functions. Separate suitably reliable, robust, and timely price oracles should be implemented/integrated where needed.  
3. It is considered most secure to favor the Vault over users in calculations, eg:  
round down when calculating:  
   - how many shares to issue to users for a certain amount of assets deposited  
   - how many assets to transfer to users for burning a certain amount of shares  

    round up when calculating:  
   - how many shares users have to burn to receive a given amount of assets  
   - how many assets users have to deposit to receive a certain amount of shares  