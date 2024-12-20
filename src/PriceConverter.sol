// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //  Address - 0xF0d50568e3A7e8259E16663972b11910F89BD8e7
        //  ABI
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0xF0d50568e3A7e8259E16663972b11910F89BD8e7
        // );
        // (uint80 roundId, int256 price,uint256 startedAt ,uint256 updatedAt , uint80 answeredInRound) = priceFeed.latestRoundData();
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        // (2000_000000000000000000 * 1_000000000000000000) / 1e18
        //  $2000 = 1ETH ;
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0xF0d50568e3A7e8259E16663972b11910F89BD8e7)
                .version();
    }
}
