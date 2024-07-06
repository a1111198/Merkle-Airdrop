// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirDrop is Script {
    error ClaimAirDrop__InvalidSignatureLength();
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 AMOUNT = 25e18;
    bytes32 PROOF1 =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF1, PROOF2];
    bytes private signature =
        hex"85e58e2d1dc3f7c36f3f360ac284d4219b9576dafd339f4e0f3bfdcaa7226bd93fe434de682e055b6d3c057055ba2f4bc5a2b48be472ab9bd1845b24dd6ce3841c";

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(contractAddress);
    }

    function claimAirdrop(address airdrop) public {
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(airdrop);
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = spliSig(signature);
        merkleAirdrop.claim(CLAIMING_ADDRESS, AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function spliSig(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirDrop__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
