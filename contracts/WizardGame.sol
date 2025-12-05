// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title WizardGame
/// @notice On-chain RPG-style progression system using MANA (ERC20),
///         with optional NFT gating or bonuses in the future.
contract WizardGame is Ownable {
    // ========================================================
    //                       STATE
    // ========================================================

    IERC20 public immutable wizardToken;  // MANA token

    // ========================================================
    //                   CONSTRUCTOR
    // ========================================================

    constructor(address _manaToken) Ownable(msg.sender) {
        require(_manaToken != address(0), "Invalid token address");
        wizardToken = IERC20(_manaToken);
    }
}
