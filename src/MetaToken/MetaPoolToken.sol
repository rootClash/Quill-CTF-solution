pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CurvePool.sol";
import "./CurveToken.sol";


contract MetaPoolToken is ERC20 {
    CurveToken lpToken; // Address of LP token
    CurvePool basePool; // Address of the BasePool contract

    constructor(
        // current LP token
        CurveToken _lpToken,
        // pool contract
        CurvePool _basePool
    ) ERC20("Meta LP Token", "MLP") {
        lpToken = _lpToken;
        basePool = _basePool;
    }

    // @answer the pool can be manipulated and and can be used.
    function mint(uint256 _lpAmount) external {
        // current virtual price of 1 LP token
        // amount * pool contract
        // 1e18 * 200e18 / 1e18 = 200e18;
        uint256 p = (_lpAmount * basePool.get_virtual_price()) / 1e18;

        require(ERC20(lpToken).transferFrom(msg.sender, address(this), _lpAmount), "KP transfer failed");

        _mint(msg.sender, p);
    }

    // @question @what if get_virtual_price() can be manipulated and stale price can be used?
    function burn(uint256 p) external {

        uint256 lpAmount = (p * 1e18) / basePool.get_virtual_price();

        require(balanceOf(msg.sender) >= p, "Insufficient balance");
        _burn(msg.sender, p);

        require(ERC20(lpToken).transfer(msg.sender, lpAmount), "KP transfer failed");
    }
}
