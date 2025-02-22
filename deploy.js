require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy the NFT contract first (if needed by other facets)
  const JiblycoinNFT = await ethers.getContractFactory("JiblycoinNFT");
  const jiblyNFT = await JiblycoinNFT.deploy(
    "Jiblycoin NFT",          // Name
    "JBNFT",                 // Symbol
    "https://base-uri.com/", // Base URI
    deployer.address         // Admin
  );
  await jiblyNFT.deployed();
  console.log("JiblycoinNFT deployed to:", jiblyNFT.address);

  // Now deploy your final Diamond contract (the wrapper) named "Jiblycoin"
  // Its constructor expects (address _admin, bytes memory _initCalldata)
  // We pass the deployer's address and "0x" (an empty bytes string)
  const Jiblycoin = await ethers.getContractFactory("Jiblycoin");
  const diamond = await Jiblycoin.deploy(deployer.address, "0x");
  await diamond.deployed();
  console.log("Jiblycoin (Diamond) deployed to:", diamond.address);

  // Define the facet names to be deployed and wired.
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

  // Deploy each facet
  for (const name of facetNames) {
    const FacetFactory = await ethers.getContractFactory(name);
    const facet = await FacetFactory.deploy();
    await facet.deployed();
    console.log(`${name} deployed at: ${facet.address}`);
    deployedFacets[name] = facet;
  }

  // Helper function to get selectors from a facet (skipping any functions that include "init")
  function getSelectors(contractInstance) {
    const selectors = [];
    const functionFragments = contractInstance.interface.fragments.filter(
      (f) => f.type === "function"
    );
    for (const frag of functionFragments) {
      if (frag.name.includes("init")) continue;
      const selector = contractInstance.interface.getSighash(frag);
      selectors.push(selector);
    }
    return selectors;
  }

  // Build an array of facet cuts for wiring the diamond.
  const DSFacetCut = [];
  for (const name of facetNames) {
    const facet = deployedFacets[name];
    const selectors = getSelectors(facet);
    DSFacetCut.push({
      facetAddress: facet.address,
      selectors: selectors
    });
    console.log(`Facet ${name} selectors:`, selectors);
  }

  // Wire the facets into your diamond.
  // This assumes your Diamond (or Jiblycoin) contract has a function called "setFacets"
  const tx = await diamond.setFacets(DSFacetCut);
  await tx.wait();
  console.log("Facets wired to diamond.");

  // For the staking facet, set the NFT contract address (if applicable)
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
