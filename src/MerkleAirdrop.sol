// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {console} from "forge-std/Test.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    ///////////////////
    /////  error    ///
    ///////////////////

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    ///////////////////
    /////  events    ///
    ///////////////////

    event Claimed(address indexed to, uint256 amount);

    ///////////////////
    /////  typed Data    ///
    ///////////////////
    struct AirDropClaim {
        address account;
        uint256 amount;
    }

    //////////////////////////
    /////storage variables///
    ////////////////////////

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airDropToken;
    mapping(address claimer => bool claimed) s_airdropClaimed;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirDropClaim(address account, uint256 amount)");

    //////////////////////////
    /////Constructor/////////
    ////////////////////////

    constructor(
        bytes32 merkleRoot,
        IERC20 airDropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airDropToken = airDropToken;
    }

    //////////////////////////
    //External Functions/////
    ////////////////////////

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_airdropClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if (
            !_isValidSignature(
                account,
                getMessageDigest(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        console.logBytes32(leaf);
        console.logBytes32(i_merkleRoot);
        for (uint i = 0; i < merkleProof.length; i++) {
            console.logBytes32(merkleProof[i]);
        }

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_airdropClaimed[account] = true;
        emit Claimed(account, amount);
        i_airDropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private pure returns (bool) {
        (address signer, , ) = ECDSA.tryRecover(digest, v, r, s);
        return signer == account;
    }

    function getMessageDigest(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirDropClaim({account: account, amount: amount})
                    )
                )
            );
    }
}
