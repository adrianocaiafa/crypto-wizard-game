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

    event XPGained(
        address indexed wizard,
        uint256 manaSpent,
        uint256 xpGained,
        uint256 newXP,
        uint256 newLevel
    );

    event SpellCast(
        address indexed from,
        address indexed target,
        uint256 manaSpent,
        uint256 xpGained,
        uint256 newLevel
    );

    event WizardCardSet(address indexed nft);
    event NftRequirementUpdated(bool required);
    event ManaWithdrawn(address indexed to, uint256 amount);

    // ========================================================
    //                   CONSTRUCTOR
    // ========================================================

    constructor(address _manaToken) Ownable(msg.sender) {
        require(_manaToken != address(0), "Invalid token address");
        wizardToken = IERC20(_manaToken);
    }

    // ========================================================
    //               ADMIN (OWNER) FUNCTIONS
    // ========================================================

    /// @notice Set or update the WizardCard NFT contract
    function setWizardCard(address _nft) external onlyOwner {
        wizardCard = IERC721(_nft);
        emit WizardCardSet(_nft);
    }

    /// @notice Require or not require NFT ownership to perform game actions
    function setNftRequiredForActions(bool required) external onlyOwner {
        nftRequiredForActions = required;
        emit NftRequirementUpdated(required);
    }

    /// @notice Withdraw accumulated MANA from this contract
    function withdrawMana(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(wizardToken.balanceOf(address(this)) >= amount, "Insufficient MANA");

        wizardToken.transfer(to, amount);
        emit ManaWithdrawn(to, amount);
    }

    // ========================================================
    //                 INTERNAL HELPERS
    // ========================================================

    function _registerWizard(address user) internal {
        if (!hasInteracted[user]) {
            hasInteracted[user] = true;
            totalUniqueWizards++;
            wizards.push(user);
            emit WizardRegistered(user);
        }
        interactionsCount[user]++;
    } 

   function _checkNFT(address user) internal view {
        if (nftRequiredForActions && address(wizardCard) != address(0)) {
            require(wizardCard.balanceOf(user) > 0, "Wizard NFT required");
        }
    }
    
    function _handleLevelUp(address user) internal {
        uint256 newLevel = xp[user] / XP_PER_LEVEL;
        if (newLevel > level[user]) {
            level[user] = newLevel;
            emit LevelUp(user, newLevel);
        }
    }

    // ========================================================
    //                   CORE GAME ACTIONS
    // ========================================================

    /// @notice Spend MANA to gain XP directly (no target)
    /// @dev Caller must approve WizardGame to spend MANA.
    function spendManaForXP(uint256 manaAmount) external {
        require(manaAmount >= MIN_MANA_SPEND, "Not enough mana");

        _checkNFT(msg.sender);
        _registerWizard(msg.sender);

        // Pull MANA from user
        wizardToken.transferFrom(msg.sender, address(this), manaAmount);

        // Convert MANA → XP
        uint256 gainedXP = manaAmount * MANA_TO_XP_RATE / 1e18;
        xp[msg.sender] += gainedXP;

        _handleLevelUp(msg.sender);

        emit XPGained(msg.sender, manaAmount, gainedXP, xp[msg.sender], level[msg.sender]);
    }
}