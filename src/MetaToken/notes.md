# Objective of The CTF
Drain as much eth+weth you can from every contract and meet the assertions

# important 
hacker eth value = 200 x reaming eth value from lending Pool

## Math rafe
totalSupply() * _frac / (10 ** decimals())

# Question
[]can i use the IERC315FlashBorrower onFlashLoan() data parameter to execute for something on Pool?
# About Protocol
The Curve is a Protocol which  3 fucntionality : DEX , lending protocol , own stableCoin
The major pool in Curve AMM are : stableSwap , CryptoSwap , FroxSwap.
stableSwap : uses `A` Amplification constant which helps in bounding the price to be pegged even when the conceterated liuidity changes with swaps.

### stableSwap
Applification cofficient : param use to maintain the price of two asset to 1 : 1.
The applification cofficient should be in between to keep the price pegged.

The dynamic fees are calculated 

### Lending Protocol 
-> fees : 0.5%


## info
Technical Requirements:

    All tokens must be ERC-20 compatible (return True/revert, True/False, or None)
    Maximum 18 decimals supported
    Oracle tokens must have precision ≤18≤18
    ERC4626 vaults support arbitrary precision for both vault and underlying tokens


