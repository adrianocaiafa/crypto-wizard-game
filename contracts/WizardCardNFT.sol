// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title WizardCardNFT
/// @notice Simple ERC721 used as wizard identity / access pass in the WizardGame ecosystem.
contract WizardCardNFT is ERC721, Ownable {

    constructor() ERC721("Wizard Card", "WIZCARD") Ownable(msg.sender) {}

}