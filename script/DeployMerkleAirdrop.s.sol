// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagleToken} from "../src/BagleToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private constant ROOT =
        0xc0b76dc79e4331b456c2e37b8c36231ed429368ad4e6291808153f2a5d64bc26;
    uint256 private constant AMOUNT_TO_MINT = 100e18;

    function run() external returns (BagleToken token, MerkleAirdrop airdrop) {
        vm.startBroadcast();
        token = new BagleToken();
        airdrop = new MerkleAirdrop(ROOT, token);
        token.mint(address(airdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();
    }
}
