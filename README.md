# Quill CTF Solutions Log

This workspace contains my Quill CTF challenge solutions and exploit writeups for a set of Solidity / EVM security challenges.

## Solved challenges in this workspace

- Road Block
- VIP Bank
- Confidential Hash
- Delegation / D31eg4t3
- Gate
- True XOR
- Pelusa
- WETH-10
- Panda Token
- WETH-11
- Donate
- Slot Puzzle
- PseudoRandom
- Invest Pool
- Voting Machine
- Private Club
- KeyCraft
- MetaToken / CurvePool
- Gold NFT
- Safe NFT
- other Solidity challenge scripts and exploit tests in this repo

## Project structure

This project includes:

- `src/` — challenge contracts and vulnerable implementations
- `test/` — Foundry exploit tests and challenge validation files
- `script/` — deployment helpers
- `lib/` — dependency libraries including Foundry std and OpenZeppelin

## Challenge coverage

The solved challenges in this repository focus on common Web3 security patterns such as:

- reentrancy
- delegatecall misuse
- flashloan-driven price manipulation
- ETH/WETH accounting issues
- unsafe arithmetic and invariant assumptions
- access control mistakes
- bad randomness assumptions
- reward and minting logic vulnerabilities

## Notes

This repository is intended as a working security lab and reference set for Quill CTF vulnerabilities. It includes both vulnerable implementations and working exploit tests used to understand how the bugs are triggered and fixed.

## Current focus

The most recent challenge in this workspace is the MetaToken / CurvePool issue, which demonstrates a stale virtual-price exploit in a pool-backed synthetic token system.

## Command to run tests

```bash
forge test
```

or for a specific challenge:

```bash
forge test --match-test testHack_meta -vv
```

## Summary

These are the Quill CTF challenges solved in this workspace and used as a learning archive for Solidity exploit development and smart contract security research.
