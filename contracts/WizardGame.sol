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
    IERC721 public wizardCard;            // optional NFT for future use

    bool public nftRequiredForActions;    // if true → user must hold NFT

    uint256 public totalUniqueWizards;
    address[] internal wizards;

    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    mapping(address => uint256) public xp;
    mapping(address => uint256) public level;
    mapping(address => uint256) public spellsCast;

    // XP and mana conversion rules
    uint256 public constant XP_PER_LEVEL       = 100;
    uint256 public constant MANA_TO_XP_RATE    = 1; // 1 MANA = 1 XP
    uint256 public constant MIN_MANA_SPEND     = 1e18; // 1 MANA minimum

    // ========================================================
    //                       EVENTS
    // ========================================================

    event WizardRegistered(address indexed wizard);
    event LevelUp(address indexed wizard, uint256 newLevel);
    
    // ========================================================
    //                   CONSTRUCTOR
    // ========================================================

    constructor(address _manaToken) Ownable(msg.sender) {
        require(_manaToken != address(0), "Invalid token address");
        wizardToken = IERC20(_manaToken);
    }
}
