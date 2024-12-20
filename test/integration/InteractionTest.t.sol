// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {

    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether ; //10e18; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; 
    uint256 constant GAS_PRICE =1;

    function setUp() external{
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public{
        vm.prank(USER);
        vm.deal(USER, 1e18);


        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        vm.prank(USER);
        vm.deal(USER, 1e18);


        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
        // fundFundMe.fundFundMe(address(fundMe));

        // address funder = fundMe.getFunder(0);  
        // assertEq(funder, USER);
    }
}