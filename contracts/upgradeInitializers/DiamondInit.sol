// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//******************************************************************************\
//* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
//* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
//*
//* Implementation of a diamond.
/******************************************************************************/

import { LibDiamond } from "../DiamondLibrary/LibDiamond.sol";
import { IDiamondLoupe } from "../DiamondInterfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../DiamondInterfaces/IDiamondCut.sol";
import { IERC173 } from "../DiamondInterfaces/IERC173.sol";
import { IERC165 } from "../DiamondInterfaces/IERC165.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

// Adding parameters to the `init` or other functions you add here can make a single deployed
// DiamondInit contract reusable accross upgrades, and can be used for multiple diamonds.

contract DiamondInit {    

    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibDiamond.TokenPoolStorage storage tps = LibDiamond.tokenPoolStorage();
        tps.pools[LibDiamond.PoolId.ECOSYSTEM].cap = LibDiamond.ECOSYSTEM_POOL;
        tps.pools[LibDiamond.PoolId.COMMUNITY].cap = LibDiamond.COMMUNITY_POOL;
        tps.pools[LibDiamond.PoolId.VESTING].cap = LibDiamond.VESTING_POOL;
        tps.pools[LibDiamond.PoolId.TREASURY].cap = LibDiamond.TREASURY_POOL;
        tps.pools[LibDiamond.PoolId.LIQUIDITY].cap = LibDiamond.LIQUIDITY_POOL;

        LibDiamond.AmbassadorProgramStorage storage aps = LibDiamond.ambassadorProgramStorage();
        aps.maxFoundingAmbassadors = LibDiamond.MAX_FOUNDING_AMBASSADORS;
        aps.creatorShareBps = LibDiamond.CREATOR_SHARE_BPS;
        aps.ambassadorShareBps = LibDiamond.AMBASSADOR_SHARES_BPS;
        aps.daoTreasuryShareBps = LibDiamond.DAO_TREASURY_SHARES_BPS;
        aps.reviewerShareBps = LibDiamond.REVIEWER_SHARES_BPS;
        aps.paused = false;
        aps.usdcToken = 0x8717F3105Ea6c1a1c6102ec9B095CB7Ad63B4fd9; // Sepolia USDC
        aps.daoTreasury = address(this); // Diamond acts as the DAO treasury

        // Level requirements (cumulative downline sales in USDC with 6 decimals)
        aps.levelRequirements[1] = 0;
        aps.levelRequirements[2] = 5000 * 10**6;     // $5,000
        aps.levelRequirements[3] = 25000 * 10**6;    // $25,000
        aps.levelRequirements[4] = 100000 * 10**6;   // $100,000
        aps.levelRequirements[5] = 500000 * 10**6;   // $500,000

        // Commission rates in basis points (100 = 1%)
        aps.levelCommissionRates[1] = 1000;  // 10%
        aps.levelCommissionRates[2] = 1200;  // 12%
        aps.levelCommissionRates[3] = 1400;  // 14%
        aps.levelCommissionRates[4] = 1600;  // 16%
        aps.levelCommissionRates[5] = 1800;  // 18%

        // Token rewards per transaction (with 18 decimals)
        aps.levelTokenRewards[1] = 5 * 10**18;   // 5 tokens
        aps.levelTokenRewards[2] = 8 * 10**18;   // 8 tokens
        aps.levelTokenRewards[3] = 10 * 10**18;  // 10 tokens
        aps.levelTokenRewards[4] = 15 * 10**18;  // 15 tokens
        aps.levelTokenRewards[5] = 20 * 10**18;  // 20 tokens

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 
    }

}