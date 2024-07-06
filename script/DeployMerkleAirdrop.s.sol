// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop, IERC20} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private constant AMOUNT_TO_MINT = 100e18;

    function run() external returns (BagelToken token, MerkleAirdrop airdrop) {
        vm.startBroadcast();
        token = new BagelToken();
        airdrop = new MerkleAirdrop(ROOT, IERC20(token));
        // Send Bagel tokens -> Merkle Air Drop contract
        token.mint(token.owner(), AMOUNT_TO_MINT);
        IERC20(token).transfer(address(airdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();
    }
}
