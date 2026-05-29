# Aave Loan Test

A Hardhat-based Solidity project using a Diamond proxy architecture for an APS token, DEX, lending, price movement, and flash-loan-related flows.

## Architecture

The system is centered on one Diamond proxy contract:

- APSDEX (Diamond proxy)

Core deployed pieces:

- APS token contract
- Diamond proxy (APSDEX)
- Diamond init contract
- Facets:
  - DiamondCutFacet
  - DiamondLoupeFacet
  - OwnershipFacet
  - ApsdexFacet
  - LendingFacet
  - MovePriceFacet
  - FlashLoanFacet

All protocol actions in tests and scripts interact through the Diamond address using facet ABIs.

## Main Components

- contracts/APS.sol
  - ERC20-style APS token used in lending and repayment flows.

- contracts/APSDEX.sol
  - Diamond proxy deployment and facet wiring.

- contracts/facets/ApsdexFacet.sol
  - APS/ETH pool operations and pricing functions.

- contracts/facets/LendingFacet.sol
  - Collateral, borrow, repay, health factor, and liquidation logic.

- contracts/facets/MovePriceFacet.sol
  - Price-moving helper logic used for testing liquidation scenarios.

- contracts/facets/FlashLoanFacet.sol
  - Flash-loan-related initialization and token withdrawal helpers.

## Deployment

Single command deployment (recommended):

```bash
npm run deploy:all -- --network hardhat
```

This script deploys APS + Diamond, initializes required facets, and writes addresses to:

- deployments/contract-addresses.json

## Tests

Run all tests:

```bash
npm test
```

Current tests target the Diamond architecture via the shared fixture:

- test/helpers/deployDiamond.js
- test/lendingTest.js
- test/FlashLoanTest.js

## Project Layout

```text
contracts/
  APS.sol
  APSDEX.sol
  DiamondInterfaces/
  DiamondLibrary/
  facets/
  mocks/
  upgradeInitializers/

scripts/
  deployAll.js
  deployDiamond.js
  dumpFacets.js
  registry.js
  upgradeDiamond.js

test/
  helpers/
    deployDiamond.js
  lendingTest.js
  FlashLoanTest.js

deployments/
  contract-addresses.json
```

## Notes

- Standalone legacy contracts/scripts were removed in favor of a single Diamond-based path.
- If running on non-local networks, set required environment variables in .env (for example FLASH_LOAN_POOL_ADDRESS when needed).
