// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/****Objective of CTF**

- Make a successful call to the callMe function.
- You should be the deployer of the contract at the given addr parameter! */

interface ICollatz {
    function collatzIteration(uint256 n) external pure returns (uint256);
}

contract Collatz {
    event Deployed(address addr);
    function deploy(uint256 n) external returns (uint256) {
        bytes
            memory bytecode = hex"6025600c60003960256000f36004358060029006600014601757600302600101601c565b600290045b60005260206000f3";

        address addr;

        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        emit Deployed(addr);

        require(addr != address(0), "CREATE failed");

        return ICollatz(addr).collatzIteration(n);
    }
}

contract CollatzPuzzle is ICollatz {
    function collatzIteration(
        uint256 n
    ) public pure override returns (uint256) {
        if (n % 2 == 0) {
            return n / 2;
        } else {
            return 3 * n + 1;
        }
    }

    function callMe(address addr) external view returns (bool) {
        // check code size
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        require(size > 0 && size <= 50, "bad code size!");

        // check results to be matching
        uint p;
        uint q;
        for (uint256 n = 1; n < 200; n++) {
            // local result
            p = n;
            for (uint256 i = 0; i < 5; i++) {
                p = collatzIteration(p);
            }
            // your result
            q = n;
            for (uint256 i = 0; i < 5; i++) {
                q = ICollatz(addr).collatzIteration{gas: 100}(q);
            }
            require(p == q, "result mismatch!");
        }

        return true;
    }
}
