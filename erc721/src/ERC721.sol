// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed spender, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address approved, uint256 tokenId) external;
    function setApprovalForAll(address spender, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address spender) external view returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Metadata  {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721TokenReceiver {
    function onERC721Received(address sender, address from, uint256 tokenId, bytes memory data) 
        external returns(bytes4);
}

contract ERC721 is IERC721, IERC721Metadata, IERC165 {

    string public name;
    string public symbol;

    uint256 private nextTokenId;

    mapping(address=>uint256) private ownerToBalance;
    mapping(uint256=>address) private tokenIdToOwner;
    mapping(uint256=>string) private tokenIdToUri;

    mapping(uint256=>address) private tokenIdToSpender;
    mapping(address=>mapping(address=>bool)) private ownerToSpenderToAll;

    modifier onlyTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Sender is not token owner.");
        _;
    }

    modifier onlyValidTokenId(uint256 tokenId) {
        require(tokenId <= nextTokenId, "Not a valid token id.");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    modifier onlyValidSender(uint256 tokenId) {
        require(
            msg.sender == ownerOf(tokenId) ||
            msg.sender == getApproved(tokenId) ||
            isApprovedForAll(ownerOf(tokenId), msg.sender),
            "Sender is neither the owner nor approved to send."
        );
        _;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return ownerToBalance[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenIdToOwner[tokenId];
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return tokenIdToUri[tokenId];
    }

    function mint(string memory tokenUri) external {
        ownerToBalance[msg.sender] += 1;
        tokenIdToOwner[nextTokenId] = msg.sender;
        tokenIdToUri[nextTokenId] = tokenUri;
        emit Transfer(address(0), msg.sender, nextTokenId);
        nextTokenId += 1;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return tokenIdToSpender[tokenId];
    }

    function isApprovedForAll(address owner, address spender) public view returns (bool) {
        return ownerToSpenderToAll[owner][spender];
    }

    function approve(address spender, uint256 tokenId) external
        onlyValidTokenId(tokenId) onlyTokenOwner(tokenId) {
        tokenIdToSpender[tokenId] = spender;
        emit Approval(msg.sender, spender, tokenId);
    }

    function setApprovalForAll(address spender, bool approved) external {
        ownerToSpenderToAll[msg.sender][spender] = approved;
        emit ApprovalForAll(msg.sender, spender, approved);
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        require(to != address(0), "Transfer to zero address is not allowed");
        tokenIdToOwner[tokenId] = to;
        ownerToBalance[from] -= 1;
        ownerToBalance[to] += 1;
        tokenIdToSpender[tokenId] = address(0);
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external
        onlyValidTokenId(tokenId) onlyValidSender(tokenId) {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public
        onlyValidTokenId(tokenId) onlyValidSender(tokenId) {

        _transfer(from, to, tokenId);
        if(to.code.length > 0) {
            require(
                IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) ==
                bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
                ,"Receiving contract did not return the magic value.");
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external
        onlyValidTokenId(tokenId) onlyValidSender(tokenId) {

        safeTransferFrom(from, to, tokenId, "");
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return(
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId 
        );
    }

}