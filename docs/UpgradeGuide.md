# Upgrade Guide

This guide explains how to upgrade facets, add new ones, and handle timelocked changes in the Jiblycoin diamond‑pattern system.

## 1. Timelock & Roles
- **Roles**: Only an address with the `UPGRADER_ROLE` can propose and execute upgrades.
- **Timelock Mechanism**: When an upgrade is proposed, the system enforces an `upgradeDelay` (set at deployment or later via `setUpgradeDelay`) before the upgrade can be executed. This delay provides a safety window for review and intervention if necessary.

## 2. Steps to Upgrade a Facet
1. **Deploy New Facet**: Deploy the new or updated facet contract logic (e.g. on BSC).
2. **Propose Upgrade**: 
   ```solidity
   diamondUpgradeFacet.proposeUpgrade(newFacetAddress);
