// Get Funds from User
// Withdraw Funds
// Set a minimum Funding value in USD

// SPDX-License-Identifier: MIT

error FundMe__NotOwner();
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConverter for uint256;

    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;
    address[] private s_funders;

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"Must be Owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // 1e18 = 1 ETH = 1000000000 GWEI = 1000000000000000000 WEI
        s_funders.push(msg.sender);
        //   addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length;
         for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
         s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call Failed");

    }

    function withdraw() public onlyOwner {
        // for(/* starting index; ending index; step amount */)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // msg.sender = address where payable(msg.sender) = payable address
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");
        // call
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call Failed");
    }

    function getVersion() public view returns (uint256) {
        // return
        //     AggregatorV3Interface(0xF0d50568e3A7e8259E16663972b11910F89BD8e7)
        //         .version();
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    /**
    View / Pure functions (Getter) */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }
}
