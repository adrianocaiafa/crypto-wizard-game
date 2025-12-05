// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/// @title WizardToken (MANA)
/// @notice ERC20 used as mana in the Wizard Game ecosystem.
///         Users can claim free initial tokens to start playing.
contract WizardToken is ERC20 {
    uint256 public constant CLAIM_AMOUNT = 1000 * 1e18;

    mapping(address => bool) public hasClaimed;

    constructor() ERC20("Wizard Mana", "MANA") {}

    /// @notice Allows each wallet to claim a one-time amount of MANA.
    function claim() external {
        require(!hasClaimed[msg.sender], "Already claimed");

        hasClaimed[msg.sender] = true;
        _mint(msg.sender, CLAIM_AMOUNT);
    }
}