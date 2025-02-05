# Upgrade Guide

Outlines how to upgrade facets, add new ones, and handle timelocked changes.

## 1. Timelock & Roles
- Upgrades can only be done by an address with `UPGRADER_ROLE`.
- Propose an upgrade, wait `upgradeDelay`, then execute.

## 2. Steps to Upgrade a Facet
1. **Deploy New Facet**: Deploy the new or updated facet contract logic on BSC.
2. **Propose Upgrade**: 
   ```solidity
   diamondUpgradeFacet.proposeUpgrade(newFacetAddress);
