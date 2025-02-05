require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const JiblycoinNFT = await ethers.getContractFactory("JiblycoinNFT");
  const jiblyNFT = await JiblycoinNFT.deploy("Jiblycoin NFT", "JBNFT", "https://base-uri.com/", deployer.address);
  await jiblyNFT.deployed();
  console.log("JiblycoinNFT deployed to:", jiblyNFT.address);

  const Diamond = await ethers.getContractFactory("JiblycoinDiamond");
  const diamond = await Diamond.deploy();
  await diamond.deployed();
  console.log("Diamond deployed to:", diamond.address);

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

  for (const name of facetNames) {
    const FacetFactory = await ethers.getContractFactory(name);
    const facet = await FacetFactory.deploy();
    await facet.deployed();
    console.log(`${name} deployed at: ${facet.address}`);
    deployedFacets[name] = facet;
  }

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

  for (const name of facetNames) {
    const facet = deployedFacets[name];
    const selectors = getSelectors(facet);
    console.log(`Wiring ${name} with selectors:`, selectors);
    for (const selector of selectors) {
      const tx = await diamond.setFacet(selector, facet.address);
      await tx.wait();
      console.log(`Selector ${selector} set to facet ${name} (${facet.address})`);
    }
  }

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
