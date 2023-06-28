// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Import the Chainlink Oracle contract for price feed
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract nUSD {
    uint256 public totalSupply;
    uint256 public  exchangeRate;
    mapping(address => uint256) public balanceOf;

    AggregatorV3Interface internal priceFeed;

    event Deposit(address indexed depositor, uint256 ethAmount, uint256 nusdAmount);

    constructor() {
        // ETH / USD
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

 // Deposit ETH and receive nUSD
    function deposit() external payable {
        uint256 ethAmount = msg.value;
        require(ethAmount > 0, "Deposit amount must be greater than zero");

        (, int256 price, , , ) = priceFeed.latestRoundData();
        exchangeRate = uint256(price); // Current exchange rate

        uint256 nusdAmount = ethAmount * exchangeRate / 2; // 50% of deposited ETH
        require(nusdAmount > 0, "Deposit amount must result in non-zero nUSD");

        balanceOf[msg.sender] += nusdAmount;
        totalSupply += nusdAmount;

        emit Deposit(msg.sender, ethAmount, nusdAmount);
    }


    // Redeem all nUSD and convert to Ether based on current exchange rate
function redeem() external {
    uint256 nusdAmount = balanceOf[msg.sender];
    require(nusdAmount > 0, "No nUSD balance to redeem");

    uint256 ethAmount = nusdAmount * exchangeRate * 2; // Double the value to redeem ETH

    balanceOf[msg.sender]=0;
    totalSupply -= nusdAmount;

    // Transfer ETH to the redeemer
    payable(msg.sender).transfer(ethAmount);
}

    // Get the current nUSD balance of an address
    function getBalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }

    // Get the total supply of nUSD
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // Get the contract owner
    function owner() internal view returns (address) {
        return address(this);
    }
}
