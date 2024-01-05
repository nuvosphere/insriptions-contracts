// contracts/Nip20Contract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma abicoder v2;

import "./INip20Contract.sol";

contract Nip20Contract is INip20Contract {
    constructor() {}

    function nip20_mint(
        address recipient,
        bytes32 ticker,
        uint256 id,
        uint256 amount
    ) external override returns (bool result) {

        //you can choose to add additonal logic to determine
        //the minting logic. as well as burning more gas.
        //
        emit NIP20TokenEvent_mint(
            msg.sender,
            recipient,
            ticker,
            id,
            amount
        );
        result = true;
        return result;
    }

    function nip20_AllowMint(
        address sender,
        address recipient,
        bytes32 ticker,
        uint256 amount
    ) external override view returns (bool result) {

        // if return true, the indexer allow regular means of minting,
        // without enforcing
        result = false;
        return result;
    }
}
