/**
 *Submitted for verification at basescan.org on 2025-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title NFTStore
 * @dev Contrat ERC-721 sans OpenZeppelin avec :
 *      - Adoption et libération de NFT
 *      - Création aléatoire de NFT avec métadonnées
 *      - Transfert conforme ERC-721
 */
contract NFTStore {

    string public name = "NFTStore";
    string public symbol = "NFTS";
    address public owner;
    uint256 private _tokenIds;

    mapping(address => bool) private adoptedNFTs;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _nftMetadataURIs;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event NFTAdopted(address indexed adopter);
    event NFTReleased(address indexed releaser);
    event NFTCreated(address indexed owner, uint256 tokenId, string metadataURI);

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous n'etes pas le proprietaire.");
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(_owners[tokenId] == msg.sender, "Vous n'etes pas le proprietaire de ce NFT.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function adoptNFT() external {
        require(!adoptedNFTs[msg.sender], "Vous avez deja adopte un NFT.");
        adoptedNFTs[msg.sender] = true;
        emit NFTAdopted(msg.sender);
    }

    function releaseNFT() external {
        require(adoptedNFTs[msg.sender], "Vous n'avez pas de NFT a liberer.");
        adoptedNFTs[msg.sender] = false;
        emit NFTReleased(msg.sender);
    }

    function hasAdoptedNFT(address user) external view returns (bool) {
        return adoptedNFTs[user];
    }

    function createRandomNFT(string memory metadataURI) external onlyOwner {
        _tokenIds++;
        _mint(msg.sender, _tokenIds, metadataURI);
    }

    function _mint(address to, uint256 tokenId, string memory metadataURI) internal {
        require(to != address(0), "Adresse invalide.");
        require(_owners[tokenId] == address(0), "Token deja existant.");

        _owners[tokenId] = to;
        _balances[to]++;
        _nftMetadataURIs[tokenId] = metadataURI;

        emit Transfer(address(0), to, tokenId);
        emit NFTCreated(to, tokenId, metadataURI);
    }

    function getNFTMetadataURI(uint256 tokenId) external view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token inexistant.");
        return _nftMetadataURIs[tokenId];
    }

    function totalNFTSupply() external view returns (uint256) {
        return _tokenIds;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token inexistant.");
        return tokenOwner;
    }

    function balanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }

    function approve(address to, uint256 tokenId) external onlyTokenOwner(tokenId) {
        _tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(_owners[tokenId] != address(0), "Token inexistant.");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address ownerAddr, address operator) external view returns (bool) {
        return _operatorApprovals[ownerAddr][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            msg.sender == from ||
            msg.sender == _tokenApprovals[tokenId] ||
            _operatorApprovals[from][msg.sender],
            "Non autorise a transferer."
        );
        require(_owners[tokenId] == from, "Le token n'appartient pas a l'expediteur.");
        require(to != address(0), "Adresse de destination invalide.");

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}
