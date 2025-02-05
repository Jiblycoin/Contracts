// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";
import "../structs/JiblycoinStructs.sol";

contract JiblycoinCoreFacet {
    event BridgeParametersUpdated(address indexed bridgeContract, uint256 l2ChainId);
    event GovernanceParametersUpdated(uint256 quorumPercentage, uint64 minHoldingDuration, uint16 votingRewardPercentage);

    function setBridgeParameters(JiblycoinStructs.BridgeParameters memory _bridgeParams) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.bridgeParams = _bridgeParams;
        emit BridgeParametersUpdated(_bridgeParams.bridgeContract, _bridgeParams.l2ChainId);
    }
    
    function getBridgeParameters() external view returns (JiblycoinStructs.BridgeParameters memory) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        return ds.bridgeParams;
    }
    
    function updateGovernanceParameters(JiblycoinStructs.GovernanceParameters memory _governanceParams) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(msg.sender == ds.adminWallet, "Not authorized");
        ds.governanceParams = _governanceParams;
        emit GovernanceParametersUpdated(_governanceParams.quorumPercentage, _governanceParams.minHoldingDuration, _governanceParams.votingRewardPercentage);
    }
}
