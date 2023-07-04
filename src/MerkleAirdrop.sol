// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    ///////////////////
    /////  error    ///
    ///////////////////

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    ///////////////////
    /////  events    ///
    ///////////////////

    event Claimed(address indexed to, uint256 amount);
    //////////////////////////
    /////storage variables///
    ////////////////////////

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airDropToken;
    mapping(address claimer => bool claimed) s_airdropClaimed;

    constructor(bytes32 merkleRoot, IERC20 airDropToken) {
        i_merkleRoot = merkleRoot;
        i_airDropToken = airDropToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (s_airdropClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_airdropClaimed[account] = true;
        emit Claimed(account, amount);
        i_airDropToken.safeTransfer(account, amount);
    }
}
