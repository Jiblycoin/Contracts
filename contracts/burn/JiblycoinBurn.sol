// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";

/**
 * @title JiblycoinBurn
 * @dev Implements a burning mechanism with rate limiting.
 */
contract JiblycoinBurn {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);
    event JiblyPointsBurned(address indexed user, uint256 amount);

    constructor() {
        _status = _NOT_ENTERED;
        _paused = false;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier onlyAdmin() {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(msg.sender == ds.adminWallet, "Not authorized");
        _;
    }

    function pause() external onlyAdmin {
        require(!_paused, "Pausable: already paused");
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyAdmin {
        require(_paused, "Pausable: not paused");
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function burnJiblyPoints(uint256 amount) external whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.BurnZero();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.balances[msg.sender] >= amount, Errors.InsufficientBalance());
        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;
        ds.totalBurned += amount;
        emit JiblyPointsBurned(msg.sender, amount);
    }
}
