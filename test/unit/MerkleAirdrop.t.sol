// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagleToken} from "../../src/BagleToken.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    bytes32 private constant ROOT =
        0x3e93831d5aec7426870165bd785ff8a3b3bc4bff63cefb371730813c39c83541;
    bytes32 private constant PROOF1 =
        0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89;
    bytes32 private constant PROOF2 =
        0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394;
    bytes32[] private PROOF = [PROOF2, PROOF1];

    uint256 private constant AMOUNT_TO_MINT = 100e18;
    uint256 private constant AMOUNT_TO_CLAIM = 25e18;

    BagleToken s_token;
    MerkleAirdrop s_airdrop;
    address user;
    uint256 privateKey;

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deploy = new DeployMerkleAirdrop();
            (s_token, s_airdrop) = deploy.run();
        } else {
            s_token = new BagleToken();
            s_airdrop = new MerkleAirdrop(ROOT, s_token);
            s_token.mint(address(s_airdrop), AMOUNT_TO_MINT);
        }
        (user, privateKey) = makeAddrAndKey("user");
    }

    function testCanClam() external {
        vm.startPrank(user);
        uint256 initialBalance = s_token.balanceOf(user);

        s_airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
        uint256 endingBalance = s_token.balanceOf(user);
        console.log(endingBalance);

        assert(endingBalance - initialBalance == AMOUNT_TO_CLAIM);
    }
}
