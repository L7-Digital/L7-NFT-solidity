// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "./L7ERC721Enumerable.sol";
import "../../lib/utils/cryptography/draft-EIP712.sol";

contract L7ERC721LazyMint is L7ERC721Enumerable, EIP712 {    
    mapping(address => bool) public signers;

    string private constant SIGNING_DOMAIN = "L7NFT";
    string private constant SIGNATURE_VERSION = "1";

    /**
     * @dev Create a new L7NFTLazyMint contract and and assign `DEFAULT_ADMIN_ROLE, MINTER_ROLE` for the creator.
     * This construction function should be called from an exchange.
     *
     */
    constructor() L7ERC721Enumerable() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {}

    function addSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "ERR_SIGNER_IS_ZERO_ADDRESS");
        signers[_signer] = true;
    }

    function removeSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "ERR_SIGNER_IS_ZERO_ADDRESS");
        signers[_signer] = false;
    }

    function equip(uint256 tokenId, bytes calldata signature)
    external
    {
        address _signer = _verify(_hash(msg.sender, tokenId), signature);
        
        require(signers[_signer], "ERR_INVALID_SIGNATURE");

        equip(tokenId);
    }

    function redeem(address owner, address redeemer, uint256 tokenId, bytes calldata signature)
    external
    {
        address _signer = _verify(_hash(owner, tokenId), signature);
        
        require(signers[_signer], "ERR_INVALID_SIGNATURE");
        
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "MUST_BE_OWNER_OR_APPROVED");
        
        redeem(owner, tokenId);
        
        if(owner != redeemer){
            _safeTransfer(owner, redeemer, tokenId, "");
        }
    }

    /// @notice Returns a hash of the given PendingNFT, prepared using EIP712 typed data hashing rules.
    function _hash(address owner, uint256 tokenId)
    internal view returns (bytes32)
    {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("L7NFT(address owner, uint256 tokenId)"),
                owner,
                tokenId
            )));
    }

    /**
     * @dev Returns the signer for a pair of digested message and signature.
     */
    function _verify(bytes32 digest, bytes memory signature)
    internal pure returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, digest));
        return ECDSA.recover(prefixedHash, signature);
    }
}
