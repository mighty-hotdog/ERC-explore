# Exploring ERC20

This project explores ERC20 and other related standards that form the foundation of the Ethereum crypto-defi-verse.  
https://eips.ethereum.org/EIPS/eip-20  

## Related token standards:  

-   **ERC223**: Replaces ERC20 standard.  
                Modifies original ERC20 `transfer()` function to call a `tokenReceived()` function on the receiver  
                if receiver is a contract. Reverts if `tokenReceived()` not implemented.  
                https://eips.ethereum.org/EIPS/eip-223  

-   **ERC677**: Add-on to ERC20 standard.  
                Adds new function `transferAndCall()` which transfers tokens to a receiver, then calls `onTokenTransfer()`  
                function on the receiver if receiver is a contract.  
                Full backward compatibility w/ existing ERC20 receiving contracts w/o `onTokenTransfer()` by treating the  
                token as an ERC20 and applying the original ERC20 methods `transfer()`, `transferFrom()`, `approve()` on it.  
                https://github.com/ethereum/EIPs/issues/677  

-   **ERC1363**: Replaces ERC20 standard. For reference.  
                 Similiar design intent to ERC677 but adds `transferAndCall()`, `transferFromAndCall()` `approveAndCall()`  
                 functions, which call `onTransferReceived()` and `onApprovalReceived()` on receiving contracts.  
                 Requires full implementation of ERC20.  
                 Full backward compatibility w/ existing ERC20 receiving contracts w/o `onTransferReceived()` and/or  
                 `onApprovalReceived()` by treating the token as an ERC20 and applying the original ERC20 methods  
                 `transfer()`, `transferFrom()`, `approve()` on it.  
                 https://eips.ethereum.org/EIPS/eip-1363  

-   **ERC777**: Another attempt to replace ERC20 standard. For reference.  
                https://eips.ethereum.org/EIPS/eip-777  

-   **ERC2612**: EIP-20 approvals via EIP-712 secp256k1 signatures. Relies on EIP-191 for hashing structured data.  
                 https://eips.ethereum.org/EIPS/eip-2612  

-   **ERC4626**: Tokenized vaults for ERC20 tokens.  
                 https://eips.ethereum.org/EIPS/eip-4626  

-   **ERC165**: Standard interface detection for any smart contract.  
                https://eips.ethereum.org/EIPS/eip-165  

-   **ERC1155**: Multi token standard. Provides standard interface for contracts that manage multiple token types.  
                 https://eips.ethereum.org/EIPS/eip-1155  

-   **ERC6909**: Minimal multi token standard.  
                 https://eips.ethereum.org/EIPS/eip-6909  

-   **ERC3156**: Flash loan standard.  
                 https://eips.ethereum.org/EIPS/eip-3156  

-   **ERC4337**: Account abstraction standard.  
                 https://eips.ethereum.org/EIPS/eip-4337  

-   **ERC721**: A standard interface for non-fungible tokens. Note the related ERC721a.  
                https://eips.ethereum.org/EIPS/eip-721  

-   **ERC2981**: A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable  
                 universal support for royalty payments across all NFT marketplaces and ecosystem participants.  
                 https://eips.ethereum.org/EIPS/eip-2981  

## Requirements for compiling and running the project

To compile and run this code, you will need to download and install 
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and
[foundry](https://getfoundry.sh/).  

In addition, you will need to install the following Solidity libraries:  

```
forge install foundry-rs/forge-std --no-commit
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

## Quickstart

If you fulfill all the requirements described above, you may proceed to clone the project to your local machine and build it.
```
git clone https://github.com/mighty-hotdog/ERC-explore
cd ERC-explore
forge build
```

## TODOs
1. DONE ~~Complete ERC1363 implementation~~
2. KIV ~~Implement OnlyOneCallGuard~~
3. Create and run tests for the whole suite:
   1. ERC20SampleCustomToken
   2. ERC20SampleWrappedToken
   3. ERC1155SampleMultiToken
   4. ERC1363SampleCustomToken
4. Implement ERC777 + tests
5. Implement ERC4626 + tests
6. Implement ERC6909 + tests
7. Implement ERC4337 + tests
8. Implement ERC3156 + tests