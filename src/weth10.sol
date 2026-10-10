pragma solidity ^0.8.0;

/**The contract currently has 10 ethers. (Check the Foundry configuration.)
You are Bob (the White Hat). Your job is to rescue all the funds from the contract, starting with 1 ether, in only one transaction */
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {console} from "@forge-std/console.sol";

// The Messi Wrapped Ether
contract WETH10 is ERC20("Messi Wrapped Ether", "WETH10"), ReentrancyGuard {
    receive() external payable {
        console.log("Ether Received!");
        deposit();
    }

    function _burnAll() internal {
        _burn(msg.sender, balanceOf(msg.sender));
    }

    function deposit() public payable nonReentrant {
        //@question why no check one msg.value? can 0 amount can be deposited?
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) external nonReentrant {
        // @question 
        Address.sendValue(payable(msg.sender), wad);
        _burn(msg.sender, wad);
    }

    function withdrawAll() external nonReentrant {
        // acting as a transfer function
        console.log("WETH10 current balanc inside the contract : " , address(this).balance );
        Address.sendValue(payable(msg.sender), balanceOf(msg.sender));                                        

        
        console.log("WETH10 current balanc inside the contract : " , address(this).balance );
        _burnAll();
    }

    /// @notice Request a flash loan in ETH
    function execute(address receiver, uint256 amount, bytes calldata data) external nonReentrant {
        // @question why it does not have a interanl accounting?
        // @question can it affect?
        // @notice it is getting the balance of ether (not wrapped eth)

        // previous balance = 100 ether
        uint256 prevBalance = address(this).balance;
        
        Address.functionCallWithValue(receiver, data, amount);

        // current balance : 100 ether + fees wagera bhi add hota hai!
        require(address(this).balance >= prevBalance, "flash loan not returned");
    }
}