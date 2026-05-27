//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

library EcosystemLib {
    struct Data {
        uint256 nextCourseId;
        uint256 nextChapterId;
        uint256 nextLessonId;
        uint256 nextQuizId;
        uint256 nextQuestionId;
        uint256 nextChoiceId;
        uint256 nextCredentialID;
        uint256 nextPurchaseId;
        uint256 nextCommissionDistributionId;
        uint256 nextAmbassadorId;

        // Level requirements (USDC, 6 decimals)
        mapping(uint8 => uint256) levelRequirements;

        // Commission rates (basis points)
        mapping(uint8 => uint256) levelCommissionRates;

        // Token rewards per transaction (18 decimals)
        mapping(uint8 => uint256) levelTokenRewards;

        // Token addresses
        address usdcToken;
        address daoTreasury;

        //nextPurchaseId
        bool paused;
    }   

    function initialize(Data storage self) internal {
        self.nextCourseId = 1;
        self.nextChapterId = 1;
        self.nextLessonId = 1;
        self.nextQuizId = 1;
        self.nextQuestionId = 1;
        self.nextChoiceId = 1;
        self.nextCredentialID = 1;
        self.nextPurchaseId = 1;
        self.nextCommissionDistributionId = 1;
        self.nextAmbassadorId = 1;

        //levelRequirement initialization
        self.levelRequirements[1] = 0;// $0
        self.levelRequirements[2] = 5000 * 10**6;// $5,000
        self.levelRequirements[3] = 25000 * 10**6;// $25,000
        self.levelRequirements[4] = 100000 * 10**6;// $100,000
        self.levelRequirements[5] = 500000 * 10**6;// $500,000

        // Initialize commission rates (in basis points)
        self.levelCommissionRates[1] = 1000; // 10%
        self.levelCommissionRates[2] = 1200; // 12%
        self.levelCommissionRates[3] = 1400; // 14%
        self.levelCommissionRates[4] = 1600; // 16%
        self.levelCommissionRates[5] = 1800; // 18%

        // Initialize token rewards (per transaction)
        self.levelTokenRewards[1] = 5 * 10**18; // 5 $ABYT
        self.levelTokenRewards[2] = 8 * 10**18; // 8 $ABYT
        self.levelTokenRewards[3] = 10 * 10**18; // 10 $ABYT
        self.levelTokenRewards[4] = 15 * 10**18; // 15 $ABYT
        self.levelTokenRewards[5] = 20 * 10**18; // 20 $ABYT

        // Token addresses
        self.usdcToken = 0xB8AA56eF0a69ABC809a54d1c0d7fB07014Ce1C8F; // USDC contract address deployed on Sepolia testnet
        self.daoTreasury = address(0);

        //paused initialization
        self.paused = false;
    }
}