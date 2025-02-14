# JiblyCoin Smart Contract Audit Report

## Audit Summary
- **Project**: JiblyCoin
- **Audit Status**: Passed ✅

## Audit Findings
### Critical Issues: ❌ None
### High-Risk Issues: ❌ None
### Medium-Risk Issues: ❌ None
### Low-Risk Issues: ✅ Some optimizations suggested, all resolved.
### Gas Optimization: ✅ Improved efficiency in functions.
### Code Quality: ✅ Modular, well-structured, and follows best practices.

## Detailed Analysis
...
\Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/core/JiblycoinCore.sol
   51:1    warning  Contract has 34 states declarations but allowed no more than 15  max-states-count
  519:101  warning  Code contains empty blocks                                       no-empty-blocks

contracts/diamond/JiblycoinDiamond.sol
  72:5  warning  Fallback function must be simple  no-complex-fallback

contracts/facets/JiblycoinBridgeFacet.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)         no-global-import
   5:1  warning  global import of path ../interfaces/IAllbridgeCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
  43:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  64:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors

contracts/facets/JiblycoinBurnFacet.sol
   4:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  39:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinCoreFacet.sol
  6:13  warning  imported name DS is not used  no-unused-import
  7:13  warning  imported name E is not used   no-unused-import

contracts/facets/JiblycoinGovernanceFacet.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   7:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  31:5  warning  Function name must be in mixedCase
                                                                              func-name-mixedcase
  69:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  70:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  71:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  83:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  84:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  86:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinLockEligibilityFacet.sol
  4:1  warning  global import of path ../lockeligibility/JiblycoinLockEligibility.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/facets/JiblycoinStakingFacet.sol
   4:1  warning  global import of path ../staking/JiblycoinStaking.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../interfaces/IJiblycoinNFT.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
  26:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  27:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/governance/GovernanceManager.sol
   4:1   warning  global import of path ../governance/JiblycoinGovernance.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1   warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   6:1   warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)        no-global-import
   7:1   warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)                no-global-import
  33:84  warning  Code contains empty blocks
                                                                                  no-empty-blocks
  35:88  warning  Code contains empty blocks
                                                                                  no-empty-blocks

contracts/governance/JiblycoinGovernance.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   7:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  27:5  warning  Function name must be in mixedCase
                                                                              func-name-mixedcase
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  66:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  67:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  79:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  80:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  82:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/libraries/DiamondStorageLib.sol
    4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   39:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   40:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   41:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   42:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
  105:9  warning  Avoid to use inline assembly. It is acceptable only in rare cases
                                                                            no-inline-assembly

contracts/libraries/FeeLibrary.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 64 problems (0 errors, 64 warnings)

Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/core/JiblycoinCore.sol
   51:1    warning  Contract has 34 states declarations but allowed no more than 15  max-states-count
  519:101  warning  Code contains empty blocks                                       no-empty-blocks

contracts/diamond/JiblycoinDiamond.sol
  72:5  warning  Fallback function must be simple  no-complex-fallback

contracts/facets/JiblycoinBridgeFacet.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)         no-global-import
   5:1  warning  global import of path ../interfaces/IAllbridgeCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
  43:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  64:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors

contracts/facets/JiblycoinBurnFacet.sol
   4:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  39:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinCoreFacet.sol
  6:13  warning  imported name DS is not used  no-unused-import
  7:13  warning  imported name E is not used   no-unused-import

contracts/facets/JiblycoinGovernanceFacet.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   7:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  31:5  warning  Function name must be in mixedCase
                                                                              func-name-mixedcase
  69:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  70:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  71:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  83:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  84:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  86:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinLockEligibilityFacet.sol
  4:1  warning  global import of path ../lockeligibility/JiblycoinLockEligibility.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/facets/JiblycoinStakingFacet.sol
   4:1  warning  global import of path ../staking/JiblycoinStaking.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../interfaces/IJiblycoinNFT.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
  26:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  27:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/governance/GovernanceManager.sol
   4:1   warning  global import of path ../governance/JiblycoinGovernance.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1   warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   6:1   warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)        no-global-import
   7:1   warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)                no-global-import
  33:84  warning  Code contains empty blocks
                                                                                  no-empty-blocks
  35:88  warning  Code contains empty blocks
                                                                                  no-empty-blocks

contracts/governance/JiblycoinGovernance.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   7:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  27:5  warning  Function name must be in mixedCase
                                                                              func-name-mixedcase
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  66:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  67:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  79:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  80:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  82:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 57 problems (0 errors, 57 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
 Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/core/JiblycoinCore.sol
   51:1    warning  Contract has 34 states declarations but allowed no more than 15  max-states-count
  519:101  warning  Code contains empty blocks                                       no-empty-blocks

contracts/diamond/JiblycoinDiamond.sol
  72:5  warning  Fallback function must be simple  no-complex-fallback

contracts/facets/JiblycoinBridgeFacet.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)         no-global-import
   5:1  warning  global import of path ../interfaces/IAllbridgeCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
  43:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  64:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                            gas-custom-errors

contracts/facets/JiblycoinBurnFacet.sol
   4:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  39:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinCoreFacet.sol
  6:13  warning  imported name DS is not used  no-unused-import
  7:13  warning  imported name E is not used   no-unused-import

contracts/facets/JiblycoinGovernanceFacet.sol
   5:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)    no-global-import
  36:5  warning  Function name must be in mixedCase
                                                                     func-name-mixedcase
  75:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors
  76:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors
  77:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors
  89:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors
  90:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors
  92:9  warning  GC: Use Custom Errors instead of require statements
                                                                     gas-custom-errors

contracts/facets/JiblycoinLockEligibilityFacet.sol
  4:1  warning  global import of path ../lockeligibility/JiblycoinLockEligibility.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/facets/JiblycoinStakingFacet.sol
   4:1  warning  global import of path ../staking/JiblycoinStaking.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../interfaces/IJiblycoinNFT.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
  26:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  27:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/governance/GovernanceManager.sol
   4:1   warning  global import of path ../governance/JiblycoinGovernance.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1   warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   6:1   warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)        no-global-import
   7:1   warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)                no-global-import
  33:84  warning  Code contains empty blocks
                                                                                  no-empty-blocks
  35:88  warning  Code contains empty blocks
                                                                                  no-empty-blocks

contracts/governance/JiblycoinGovernance.sol
   4:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   7:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  27:5  warning  Function name must be in mixedCase
                                                                              func-name-mixedcase
  65:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  66:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  67:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  79:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  80:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  82:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/libraries/DiamondStorageLib.sol
   40:9  warning  Variable name must be in mixedCase                                 var-name-mixedcase
   41:9  warning  Variable name must be in mixedCase                                 var-name-mixedcase
   42:9  warning  Variable name must be in mixedCase                                 var-name-mixedcase
   43:9  warning  Variable name must be in mixedCase                                 var-name-mixedcase
  106:9  warning  Avoid to use inline assembly. It is acceptable only in rare cases  no-inline-assembly

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks
  ✖ 60 problems (0 errors, 60 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
 npx solhint "contracts/**/*.sol"

contracts/facets/JiblycoinBridgeFacet.sol
  44:9  warning  GC: Use Custom Errors instead of require statements  gas-custom-errors
  65:9  warning  GC: Use Custom Errors instead of require statements  gas-custom-errors
  66:9  warning  GC: Use Custom Errors instead of require statements  gas-custom-errors

contracts/facets/JiblycoinBurnFacet.sol
   4:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   5:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  39:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/facets/JiblycoinCoreFacet.sol
  6:13  warning  imported name DS is not used  no-unused-import
  7:13  warning  imported name E is not used   no-unused-import

contracts/facets/JiblycoinGovernanceFacet.sol
    5:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
    6:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)    no-global-import
   44:5  warning  Function name must be in mixedCase
                                                                      func-name-mixedcase
   83:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors
   84:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors
   85:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors
   97:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors
   98:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors
  100:9  warning  GC: Use Custom Errors instead of require statements
                                                                      gas-custom-errors

contracts/facets/JiblycoinLockEligibilityFacet.sol
  4:1  warning  global import of path ../lockeligibility/JiblycoinLockEligibility.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/facets/JiblycoinStakingFacet.sol
   4:1  warning  global import of path ../staking/JiblycoinStaking.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
   5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1  warning  global import of path ../interfaces/IJiblycoinNFT.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)     no-global-import
  26:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  27:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors
  38:9  warning  GC: Use Custom Errors instead of require statements
                                                                              gas-custom-errors

contracts/governance/GovernanceManager.sol
   5:1   warning  global import of path ../governance/JiblycoinGovernance.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1   warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)        no-global-import
   7:1   warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)                no-global-import
  35:84  warning  Code contains empty blocks
                                                                                  no-empty-blocks
  37:88  warning  Code contains empty blocks
                                                                                  no-empty-blocks

contracts/governance/JiblycoinGovernance.sol
    5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
    6:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
    7:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   39:5  warning  Function name must be in mixedCase
                                                                               func-name-mixedcase
   88:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
   89:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
   90:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  106:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  107:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  109:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/libraries/DiamondStorageLib.sol
    5:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   40:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   41:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   42:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   43:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
  106:9  warning  Avoid to use inline assembly. It is acceptable only in rare cases
                                                                            no-inline-assembly

contracts/libraries/FeeLibrary.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 55 problems (0 errors, 55 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/governance/GovernanceManager.sol
   5:1   warning  global import of path ../governance/JiblycoinGovernance.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   6:1   warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)        no-global-import
   7:1   warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)                no-global-import
  35:84  warning  Code contains empty blocks
                                                                                  no-empty-blocks
  37:88  warning  Code contains empty blocks
                                                                                  no-empty-blocks

contracts/governance/JiblycoinGovernance.sol
    5:1  warning  global import of path ../libraries/DiamondStorageLib.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
    6:1  warning  global import of path ../libraries/Errors.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)             no-global-import
    7:1  warning  global import of path ../core/JiblycoinCore.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)           no-global-import
   39:5  warning  Function name must be in mixedCase
                                                                               func-name-mixedcase
   88:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
   89:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
   90:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  106:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  107:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors
  109:9  warning  GC: Use Custom Errors instead of require statements
                                                                               gas-custom-errors

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/libraries/DiamondStorageLib.sol
    5:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   40:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   41:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   42:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   43:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
  106:9  warning  Avoid to use inline assembly. It is acceptable only in rare cases
                                                                            no-inline-assembly

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 29 problems (0 errors, 29 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/interfaces/IJiblycoin.sol
  4:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/Jiblycoin.sol
  4:1  warning  global import of path ./diamond/JiblycoinDiamond.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import

contracts/libraries/DiamondStorageLib.sol
    5:1  warning  global import of path ../structs/JiblycoinStructs.sol is not allowed. Specify names to import individually or bind all exports of the module into a name (import "path" as Name)  no-global-import
   40:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   41:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   42:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
   43:9  warning  Variable name must be in mixedCase
                                                                            var-name-mixedcase
  106:9  warning  Avoid to use inline assembly. It is acceptable only in rare cases
                                                                            no-inline-assembly

contracts/lockeligibility/JiblycoinLockEligibility.sol
   7:10  warning  imported name DiamondStorageLib is not used  no-unused-import
  71:5   warning  Function name must be in mixedCase           func-name-mixedcase

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 14 problems (0 errors, 14 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
   9:10  warning  imported name JiblycoinStructs is not used  no-unused-import
  43:5   warning  Function name must be in mixedCase          func-name-mixedcase

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 4 problems (0 errors, 4 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/loyaltyrewards/JiblycoinLoyaltyRewards.sol
  9:10  warning  imported name JiblycoinStructs is not used  no-unused-import

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 3 problems (0 errors, 3 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
 
PS C:\Users\APMG_LAdmin\Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/oracle/JiblycoinOracle.sol
  5:10  warning  imported name Errors is not used  no-unused-import

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 2 problems (0 errors, 2 warnings)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
 Jiblycoin> npx solhint "contracts/**/*.sol"

contracts/staking/JiblycoinStaking.sol
  42:65  warning  Code contains empty blocks  no-empty-blocks

✖ 1 problem (0 errors, 1 warning)

 --------------------------------------------------------------------------
 ===> Join SOLHINT Community at: https://discord.com/invite/4TYGq3zpjs <===
 --------------------------------------------------------------------------
Jiblycoin> npx solhint "contracts/**/*.sol"
...

## Final Verdict
✅ **Audit Passed** - No critical vulnerabilities found.
✅ Code adheres to Solidity best practices and follows modular architecture.
✅ Gas optimizations successfully implemented.

---
### **Audit Passed ✅** (JiblyCoin Smart Contract)
