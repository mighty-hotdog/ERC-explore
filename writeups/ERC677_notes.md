# ERC677 - "transferAndCall" extension to ERC20

## ERC20 vs ERC677
### sender sends ERC20 tokens to receiver ##################################################
#### Method 1 - approve() and transferFrom()
steps
1. sender calls `approve()` on token contract to grant receiver allowance on sender's tokens
2. (assume) receiver calls `transferFrom()` on token contract to transfer tokens from sender to self  

problems
1. need at least 2 txns to complete single transfer
2. receiver doesn't know if, who, how much, when allowance is granted to itself  
   => receiver needs to be informed so that it will proceed to call `transferFrom()`
1. if receiver is a contract, it has no way to perform any action on receiving the tokens

#### Method 2 - transfer()
steps
1. sender calls `transfer()` on token contract to directly send tokens to receiver  

problem
1. receiver doesn't know if, who, how much, when tokens were sent to itself
2. receiver has no way to perform any action on receiving the tokens  
   - no problem if receiver is EOA
   - no joy if receiver is contract
3. if receiver is a non-ERC20 contract, `transfer()` will still succeed, but tokens are now stuck on receiver contract

### sender sends ERC677 tokens to receiver #################################################
#### Method 1 - as ERC20 tokens via approve() and transferFrom()
Basically sender sends the ERC677 tokens as ERC20 tokens using ERC20 methods.

#### Method 2 - as ERC20 tokens via transfer()
Here again sender sends the ERC677 tokens as ERC20 tokens using ERC20 methods.

#### Method 3 - transferAndCall()
1. sender calls `transferAndCall()` on token contract to directly send the ERC677 tokens to receiver
2. the `transferAndCall()` function:  
   - calls ERC20 `transfer()` on self, ie: `address(this)`, to transfer tokens directly from sender to receiver
   - emits the ERC677 `Transfer()` event
   - if receiver is a contract, calls `onTokenTransfer()` on receiver contract  
   reverts if receiver doesn't implement `onTokenTransfer()`  

      Note that the revert behavior described above is not explicitly specified in the ERC677 but merely a logical implementation by yours truly.

## ERC677 Benefits
1. Sender can send ERC677 tokens as ERC20 tokens to receivers that don't have `onTokenReceived()` and continue enjoying full ERC20 functionality and also suffer all its weaknesses.
2. Sender can send ERC677 tokens to receivers that have `onTokenReceived()` defined and benefit from:  
   - receivers being "notified" upon token transfers,
   - receivers able to perform actions upon token transfers,
   - extra data field that can communicate data or a message from sender to receiver.
3. If sender uses `transferAndCall()` to send ERC677 tokens, tokens will no longer suffer getting stuck on non ERC677 compatible contracts since `transferAndCall()` will revert if receiving contract is not ERC677 compatible.  

   However if sender continues using ERC20 methods to send ERC677 tokens as ERC20 tokens, the problem of them getting stuck on non ERC20 compatible receivers remains.

## Comments
### ERC677 is fully backward compatible with ERC20.  
Because ERC677 is an addon to the ERC20 standard, hence ERC677 tokens are also ERC20 tokens, and all ERC20 methods apply to ERC677 tokens as well.

## ERC677 Adoption
Chainlink's token $LINK is the only major notable protocol that implements ERC677.