// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagleToken} from "../../src/BagleToken.sol";

contract MerkleAirdropTest is Test {
    bytes32 private constant ROOT =
        0xc0b76dc79e4331b456c2e37b8c36231ed429368ad4e6291808153f2a5d64bc26;
    bytes32 private constant PROOF1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private constant PROOF2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 private constant PROOF3 =
        0x75c8f97928ce91ce213889658dc91fb2187c8aff4a5621f26e24ce6f6e4e46d3;
    bytes32 private constant PROOF4 =
        0x7f0c22c0d293d038fbd6ac7f2e4b26b1b4d34e13bbe09c03921af5147fce3c46;
    bytes32[] private PROOF = [PROOF1, PROOF2, PROOF3, PROOF4];
    uint256 private constant AMOUNT_TO_MINT = 100e18;
    uint256 private constant AMOUNT_TO_CLAIM = 25e18;

    BagleToken s_token;
    MerkleAirdrop s_airdrop;
    address user;
    uint256 privateKey;

    function setUp() external {
        s_token = new BagleToken();
        s_airdrop = new MerkleAirdrop(ROOT, s_token);
        s_token.mint(address(s_airdrop), AMOUNT_TO_MINT);
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
