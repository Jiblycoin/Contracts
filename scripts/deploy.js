require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy the NFT contract (used later by the StakingFacet)
  const JiblycoinNFT = await ethers.getContractFactory("JiblycoinNFT");
  const jiblyNFT = await JiblycoinNFT.deploy("Jiblycoin NFT", "JBNFT", "https://base-uri.com/", deployer.address);
  await jiblyNFT.deployed();
  console.log("JiblycoinNFT deployed to:", jiblyNFT.address);

  // Deploy the Diamond contract.
  // Note: Your Diamond constructor expects an admin address and an initialization calldata (here we pass empty bytes).
  const Diamond = await ethers.getContractFactory("JiblycoinDiamond");
  const diamond = await Diamond.deploy(deployer.address, "0x");
  await diamond.deployed();
  console.log("Diamond deployed to:", diamond.address);

  // List the names of your facet contracts
  const facetNames = [
    "JiblycoinCoreFacet",
    "JiblycoinGovernanceFacet",
    "JiblycoinLoyaltyFacet",
    "JiblycoinStakingFacet",
    "JiblycoinLockEligibilityFacet",
    "JiblycoinUpgradeFacet",
    "JiblycoinBurnFacet",
    "JiblycoinBridgeFacet"
  ];

  const deployedFacets = {};

  // Deploy each facet contract
  for (const name of facetNames) {
    const FacetFactory = await ethers.getContractFactory(name);
    const facet = await FacetFactory.deploy();
    await facet.deployed();
    console.log(`${name} deployed at: ${facet.address}`);
    deployedFacets[name] = facet;
  }

  // Helper function to extract function selectors from a contract’s ABI.
  function getSelectors(contractInstance) {
    const selectors = [];
    const iface = contractInstance.interface;
    for (const fragment of iface.fragments) {
      if (fragment.type !== "function") continue;
      // Skip initializer functions (if desired)
      if (fragment.name.startsWith("init")) continue;
      const selector = iface.getSighash(fragment);
      selectors.push(selector);
    }
    return selectors;
  }

  // Build an array of facet cuts (each containing a facet’s address and its function selectors)
  const facetCuts = [];
  for (const name of facetNames) {
    const facet = deployedFacets[name];
    const selectors = getSelectors(facet);
    console.log(`Facet ${name} selectors:`, selectors);
    facetCuts.push({
      facetAddress: facet.address,
      selectors: selectors
    });
  }

  // Wire the facets into the Diamond by calling setFacets with the array of facet cuts.
  const setFacetsTx = await diamond.setFacets(facetCuts);
  await setFacetsTx.wait();
  console.log("Facet wiring complete.");

  // For the StakingFacet, set the NFT contract address so that it can check NFT ownership.
  if (deployedFacets["JiblycoinStakingFacet"]) {
    const stakingFacet = deployedFacets["JiblycoinStakingFacet"];
    const txNFT = await stakingFacet.setNFTContractAddress(jiblyNFT.address);
    await txNFT.wait();
    console.log(`NFT contract address set in StakingFacet to: ${jiblyNFT.address}`);
  }

  console.log("Deployment and facet wiring complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment error:", error);
    process.exit(1);
  });
