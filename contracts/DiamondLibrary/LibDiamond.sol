// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../DiamondInterfaces/IDiamondCut.sol";
import "./EcosystemLib.sol";

error NoSelectorsProvidedForFacetForCut(address _facetAddress);
error IncorrectFacetCutAction(uint8 _action);
error CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(bytes4 _selector);
error CannotReplaceFunctionsFromFacetWithZeroAddress(bytes4[] _selectors);
error CannotReplaceImmutableFunction(bytes4 _selector);
error CannotReplaceFunctionThatDoesNotExists(bytes4 _selector);
error RemoveFacetAddressMustBeZeroAddress(address _facetAddress);
error CannotRemoveFunctionThatDoesNotExist(bytes4 _selector);
error CannotRemoveImmutableFunction(bytes4 _selector);

library LibDiamond {
    // =========================
    // Storage Slot Positions
    // =========================
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
    bytes32 constant APS_STORAGE_POSITION = keccak256("aps.token.storage");
    bytes32 constant APSDEX_STORAGE_POSITION = keccak256("apsdex.storage");
    bytes32 constant FLASHLOAN_STORAGE_POSITION = keccak256("flashloan.storage");
    bytes32 constant LENDING_STORAGE_POSITION = keccak256("lending.data.storage");
    bytes32 constant MOVEPRICE_ENGAGEMENT_STORAGE_POSITION = keccak256("moveprice.engagement.storage");

    // =========================
    // Role Identifiers
    // =========================
    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // =========================
    // APS Constants
    // =========================
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18; // Maximum supply of APS tokens
    uint256 public constant INITIAL_SUPPLY = 100000 * 10 ** 18; // Initial supply of APS tokens

    address public owner;


    // =========================
    // Diamond Core Types
    // =========================
    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition;
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors; // Array of function selectors
    }

     struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        mapping(bytes4 => address) facets;
        address owner;
        address contractOwner;
         bytes4[] selectors;
        address[] facetAddresses;
        mapping(address => bool) authorizedFacets;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition; // Ensure this line is correctly placed
        mapping(address => uint256) facetAddressPosition; // Added this line
        mapping(address => bytes4[]) facetToSelectors; // Added this line
        mapping(bytes4 => bool) supportedInterfaces; // Added this line
        mapping(bytes32 => mapping(address => bool)) roles;
    }

    // =========================
    // Ecosystem Data Container
    // =========================
    struct APSDataStorage {
        EcosystemLib.Data data;
    }

    // =========================
    // APSFacet Storage
    // =========================
    struct apsStorage {
        IERC20 token;
        uint256 totalSupply;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }

    // =========================
    // APSDEXFacet Storage
    // =========================
    struct APSDEXStorage {
        uint256 public ethReserve;
        uint256 public apsReserve;
        uint256 public totalLiquidity;

        mapping(address => uint256) public liquidity;
    }


   

    


    // =========================
    // FlashLoanFacetFacet Storage
    // =========================
    struct FlashLoanFacetStorage {
        address payable public owner;

        mapping(address => uint256) public userOwnedFunds;
    }

    // =========================
    // Lending Facet Storage
    // =========================
    struct LendingFacetStorage {
        // =============================================================
    //                           STATE
    // =============================================================

    APS public immutable aps;
    APSDEX public immutable apsDex;

    uint256 public constant COLLATERAL_RATIO = 120; // 120%
    uint256 public constant LIQUIDATION_BONUS = 10; // 10%
    uint256 public constant PRECISION = 1e18;

    uint256 public constant INTEREST_RATE = 10; // 10% APR
    uint256 public constant YEAR = 365 days;

    uint256 public constant STAKING_APR = 15;

    uint256 public constant LIQUIDATION_GRACE_PERIOD = 24 hours;

    // =============================================================
    //                          STRUCTS
    // =============================================================

    struct Position {
        uint256 collateralETH;
        uint256 borrowedAPS;
        uint256 borrowTimestamp;
        uint256 riskTimestamp;
        uint256 stakeTimestamp;
    }

    mapping(address => Position) public positions;
    }

    // =========================
    // MovePrice Facet Storage
    // =========================
    struct MovePriceFacetStorage {
        IERC20 i_aps;
        APSDEX i_apsDex;
    }

    // =========================
    // Storage Accessors
    // =========================
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    bytes32 position = DIAMOND_STORAGE_POSITION;
    assembly {
        ds.slot := position
    }
}


    function apsStorage() internal pure returns (APSFacetStorage storage es) {
        bytes32 position = APS_FACET_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }

    function APSDEXFacetStorage() internal pure returns (APSDEXFacetStorage storage es) {
        bytes32 position = APSDEX_FACET_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }

    function FlashLoanFacetStorage() internal pure returns (FlashLoanFacetStorage storage es) {
        bytes32 position = FLASH_LOAN_FACET_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }

    function ecosystemDataStorage() internal pure returns (EcosystemDataStorage storage eds) { 
        bytes32 position = ECOSYSTEM_DATA_STORAGE_POSITION;
        assembly {
            eds.slot := position
        }
    }

    function LendingFacetStorage() internal pure returns (LendingFacetStorage storage ces) {
        bytes32 position = LENDING_FACET_STORAGE_POSITION;
        assembly {
            ces.slot := position
        }
    }

    function MovePriceFacetStorage() internal pure returns (MovePriceFacetStorage storage cgs) {
        bytes32 position = MOVE_PRICE_FACET_STORAGE_POSITION;
        assembly {
            cgs.slot := position
        }
    }

    function initializeEcosystemData() internal {
        EcosystemDataStorage storage eds = ecosystemDataStorage();
        EcosystemLib.initialize(eds.data); // Call EcosystemLib's initialize function
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().owner, "LibDiamond: Must be contract owner");
    }

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.owner = _newOwner;
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    // Role management functions
    function grantRole(bytes32 role, address account) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.roles[role][account] = true;
    }

    function revokeRole(bytes32 role, address account) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.roles[role][account] = false;
    }

    function hasRole(bytes32 role, address account) internal view returns (bool) {
        DiamondStorage storage ds = diamondStorage();
        return ds.roles[role][account];
    }

    function diamondCut(
    IDiamondCut.FacetCut[] memory _diamondCut,
    address _init,
    bytes memory _calldata
) internal {
    for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
        bytes4[] memory functionSelectors = _diamondCut[facetIndex].functionSelectors;
        address facetAddress = _diamondCut[facetIndex].facetAddress;
        if(functionSelectors.length == 0) {
            revert NoSelectorsProvidedForFacetForCut(facetAddress);
        }
        if (facetAddress == address(0)) {
            revert CannotReplaceFunctionsFromFacetWithZeroAddress(functionSelectors);
        }
        IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
        if (action == IDiamondCut.FacetCutAction.Add) {
            addFunctions(facetAddress, functionSelectors);
        } else if (action == IDiamondCut.FacetCutAction.Replace) {
            replaceFunctions(facetAddress, functionSelectors);
        } else if (action == IDiamondCut.FacetCutAction.Remove) {
            removeFunctions(facetAddress, functionSelectors);
        } else {
            revert IncorrectFacetCutAction(uint8(action));
        }
    }
    emit IDiamondCut.DiamondCut(_diamondCut, _init, _calldata);
    initializeDiamondCut(_init, _calldata);
}

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        if (selectorPosition == 0) {
            addFacet(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.facetToSelectors[_facetAddress].push(selector); // Add this line to update facetToSelectors
            // Also maintain the selectors array and facetAddressAndSelectorPosition mapping for compatibility
            uint16 selectorArrayPosition = uint16(ds.selectors.length);
            ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
            ds.facetAddressAndSelectorPosition[selector].selectorPosition = selectorArrayPosition;
            ds.selectors.push(selector);
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {        
        DiamondStorage storage ds = diamondStorage();
        if(_facetAddress == address(0)) {
            revert CannotReplaceFunctionsFromFacetWithZeroAddress(_functionSelectors);
        }
        enforceHasContractCode(_facetAddress, "LibDiamondCut: Replace facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            // Determine the current facet for this selector. Prefer selectorToFacetAndPosition,
            // but fall back to facetAddressAndSelectorPosition if necessary (compatibility).
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            if (oldFacetAddress == address(0)) {
                oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            }
            // can't replace immutable functions -- functions defined directly in the diamond in this case
            if(oldFacetAddress == address(this)) {
                revert CannotReplaceImmutableFunction(selector);
            }
            if(oldFacetAddress == _facetAddress) {
                revert CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(selector);
            }
            if(oldFacetAddress == address(0)) {
                revert CannotReplaceFunctionThatDoesNotExists(selector);
            }
            // replace old facet address
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            // keep facetAddressAndSelectorPosition in sync as well
            ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
        }
    }

    function addFacet(address _facetAddress) internal {
        DiamondStorage storage ds = diamondStorage();
        enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
        ds.facetAddresses.push(_facetAddress);
        ds.authorizedFacets[_facetAddress] = true;
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {        
        DiamondStorage storage ds = diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        if(_facetAddress != address(0)) {
            revert RemoveFacetAddressMustBeZeroAddress(_facetAddress);
        }        
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[selector];
            if(oldFacetAddressAndSelectorPosition.facetAddress == address(0)) {
                revert CannotRemoveFunctionThatDoesNotExist(selector);
            }
            
            
            // can't remove immutable functions -- functions defined directly in the diamond
            if(oldFacetAddressAndSelectorPosition.facetAddress == address(this)) {
                revert CannotRemoveImmutableFunction(selector);
            }
            // replace selector with last selector
            selectorCount--;
            if (oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
                ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition.selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    assembly {
                        let returndata_size := mload(error)
                        revert(add(32, error), returndata_size)
                    }
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}
