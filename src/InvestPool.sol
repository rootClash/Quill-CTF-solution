// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InvestPool {
    IERC20 token;
    uint public totalShares;
    bool public initialized;
    mapping(address => uint) public balance;

    modifier onlyInitializing() {
        require(initialized, "Not initialized! You are so stupid!");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
    }

    // password : hello
    function initialize(string memory password) external {
        // Password could be found in Goerli contract
        // 0xA45aC53E355161f33fB00d3c9485C77be3c808ae
        // Hint: Password length is more than 30 chars
        require(!initialized, "Already initialized");
        require(
            keccak256(abi.encode(password)) ==
                0xd54f3f1f72ee65a1481c930f1205d4ee85580eb0b14b6fbc60d81b0853dc5003,
            "Wrong password"
        );
        initialized = true;
    }

    function deposit(uint amount) external onlyInitializing {
        uint userShares = tokenToShares(amount);
        balance[msg.sender] += userShares;
        totalShares += userShares;
        // @audit unchecked return
        token.transferFrom(msg.sender, address(this), amount);
    }

    function tokenToShares(uint userAmount) public view returns (uint) {
        uint tokenBalance = token.balanceOf(address(this));
        if (tokenBalance == 0) return userAmount;
        return (userAmount * totalShares) / tokenBalance;
    }

    function sharesToToken(uint amount) public view returns (uint) {
        uint tokenBalance = token.balanceOf(address(this));
        return (amount * tokenBalance) / totalShares;
    }

    function transferFromShare(uint amount, address from) public {
        uint size;
        assembly {
            size := extcodesize(address())
        }
        require(size == 0, "code size is not 0");
        require(balance[from] >= amount, "amount is too big");
        balance[from] -= amount;
        balance[msg.sender] += amount;
    }

    function withdrawAll() external onlyInitializing {
        uint shares = balance[msg.sender];
        uint toWithdraw = sharesToToken(shares);
        balance[msg.sender] = 0;
        totalShares -= shares;
        // @audit unchecked return
        token.transfer(msg.sender, toWithdraw);
    }
}