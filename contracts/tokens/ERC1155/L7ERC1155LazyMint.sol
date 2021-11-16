// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "./L7ERC1155.sol";
import "../../lib/utils/cryptography/draft-EIP712.sol";

contract L7ERC1155LazyMint is L7ERC1155, EIP712 {
    string private constant SIGNING_DOMAIN = "L71155";
    string private constant SIGNATURE_VERSION = "1";

    /**
     * @dev Mapping for checking if minting data has been redeemed.
     */
    mapping(bytes32 => bool) private _mintHashRedeemed;

    event Logs(address creator, bytes32 digest, bytes signature, bytes32 salt);

    /**
     * @dev A struct consists of the lazy minting data.
     */
    struct MintData {
        string tokenURI;
        uint256 amount;
        uint256 salt;
        bytes signature;
    }

    /**
     * @dev Create a new L7ERC1155 contract and set the `_uri` value.
     *
     */
    constructor(string memory uri_) L7ERC1155(uri_) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
    }

    /**
     * @dev Implement a lazy minting mechanism in which the NFT-minting process is delayed until the first order is successful.
     * This function should be handled by a smart contract which is allowed by the `creator`.
     * @notice For each lazy minting data, this function should only be called once.
     * @notice It throws if
     *      - the minting data has already been redeemed.
     *      - `msg.sender` is not the `creator` or has not been approved by the `creator`.
     *      - minting data and signature are not valid.
     *      - if the `redeemer` is a contract and it cannot receive the NFT.
     * @param redeemer The address of the party that an amount of the minting token will be transferred to.
     * @param mintData The lazy minting data.
     */
    function redeem(address redeemer, MintData calldata mintData)
    public virtual returns (uint256)
    {
        bytes32 digest = _hash(mintData);
        require(!_mintHashRedeemed[digest], "ERC1155: mint data already redeemed");

        address creator = _verify(digest, mintData.signature);
        address operator = msg.sender;
        require(operator == creator || isApprovedForAll(creator, msg.sender), "ERC1155: caller is not creator nor approved");

        uint256 id = uint256(keccak256(abi.encode(creator, mintData.tokenURI)));

        // mint the token to the creator
        super._mint(creator, id, mintData.amount, "");

        // set the tokenURI
        _setTokenUri(id, mintData.tokenURI);

        // save the creator
        if (_creator[id] == address(0x0)) {
            _saveCreator(id, creator);
        }

        // set the redeemed status
        _mintHashRedeemed[digest] = true;

        // transfer the token to the redeemer
        safeTransferFrom(creator, redeemer, id, mintData.amount, "");

        return id;
    }

    /// @notice Return a hash of the given PendingNFT, prepared using EIP712 typed data hashing rules.
    function _hash(MintData calldata mintData)
    internal view returns (bytes32)
    {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("L7ERC1155(string uri,uint256 amount,uint256 salt)"),
                keccak256(bytes(mintData.tokenURI)),
                mintData.amount,
                mintData.salt
            )));
    }

    /**
     * @dev Return the signer for a pair of digested message and signature.
     */
    function _verify(bytes32 digest, bytes memory signature)
    internal pure returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, digest));
        return ECDSA.recover(prefixedHash, signature);
    }
}
