// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    bytes32 private constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 private constant PROOF1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private constant PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private PROOF = [PROOF1, PROOF2];

    uint256 private constant AMOUNT_TO_MINT = 100e18;
    uint256 private constant AMOUNT_TO_CLAIM = 25e18;

    BagelToken s_token;
    MerkleAirdrop s_airdrop;
    address user;
    address gasPayer;
    uint256 userPrivateKey;

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deploy = new DeployMerkleAirdrop();
            (s_token, s_airdrop) = deploy.run();
        } else {
            s_token = new BagelToken();
            s_airdrop = new MerkleAirdrop(ROOT, s_token);
            s_token.mint(address(s_airdrop), AMOUNT_TO_MINT);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testCanClam() external {
        uint256 initialBalance = s_token.balanceOf(user);
        bytes32 digest = s_airdrop.getMessageDigest(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        vm.prank(gasPayer);
        s_airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = s_token.balanceOf(user);
        console.log(endingBalance);

        assert(endingBalance - initialBalance == AMOUNT_TO_CLAIM);
    }
}
