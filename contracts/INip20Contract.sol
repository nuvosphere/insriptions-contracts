// contracts/INip20Contract.sol 
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9; 
pragma abicoder v2;

interface INip20Contract{ 
   event NIP20TokenEvent_transfer(address sender, address recipient, bytes32 ticker, bytes32 txhash);
   event NIP20TokenEvent_burn(address sender, bytes32 ticker, bytes32 txhash);
   event NIP20TokenEvent_transferFromPreviousOwner (address sender, address recipient, address prevOwner, bytes32 ticker, bytes32 txhash);
   event NIP20TokenEvent_mint(address sender, address recipient, bytes32 ticker, uint256 id, uint256 amount);
   event NIP721TokenEvent_mint(address sender, address recipient, bytes32 ticker, string message);
   function nip20_mint(address recipient, bytes32 ticker, uint256 id, uint256 amount) external returns (bool);
   function nip20_AllowMint(address sender, address recipient, bytes32 ticker, uint256 amount) external view returns (bool);
}
