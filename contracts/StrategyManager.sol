//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Lending } from "./Lending.sol";
import { APS } from "./APS.sol";
import { APSDEX } from "./APSDEX.sol";

contract StrategyManager {
    APS public immutable aps;
    APSDEX public immutable apsDex;

    //constants
    uint256 public constant YIELD_RATE = 5;
    uint256 public constant YEAR = 365 days;

    //EVENTS
    event DebtReduced(address indexed borrower, uint256 indexed yieldAmount);

    //constructor
    constructor(address _aps, address _apsDex){
        aps = APS(_aps);
        apsDex = APSDEX(payable(_apsDex));
    }

    //function to collect interest
    function harvestCollateralYield(address _user) internal returns (uint256) {
        require(Lending.positions[_user].collateralETH != 0, "No collateral!");

        uint256 collateral = Lending.positions[_user].collateralETH;
        uint256 yield = (collateral * (YIELD_RATE + 100)) / 100; //yield is in ETH

        //convert it to the borrowed token(APS)
        uint256 yieldInAPS = yield / apsDex.currentPrice();

        // user debt in APS
        uint256 debt = Lending.getRepayAmount(_user);

        if(yieldInAPS >= ((10 * debt) / 100)) {
            require(aps.allowance(Lending.target, address(this))>= debt, "Approve APS first");
            Lending.positions[_user].borrowedAPS -= yieldInAPS;

            Lending.updateRiskStatus(_user);
        }

        emit DebtReduced(_user, yieldInAPS);

        return yieldInAPS;
    }

}