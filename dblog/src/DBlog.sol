// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DBlog {

    struct BlogMetadata {
        bool initialized;
        uint256 blockFirstPost;
        uint256 blockLatestPost;
        uint256 postCount;
    }

    mapping(address => BlogMetadata) private authorToBlog;

    event BlogPost(address indexed author, uint256 indexed postId, string content);

    modifier onlyInitializedBlog(address author) {
        require(blogExists(author), "No blog initialized for this author.");
        _;
    }

    function initBlog() public {
        require(!blogExists(msg.sender), "Blog for author address already exists.");
        authorToBlog[msg.sender] = BlogMetadata(true, 0, 0, 0);
    }

    function blogExists(address author) private view returns (bool) {
        return authorToBlog[author].initialized;
    }

    function blogMetadata(address author) external view 
        onlyInitializedBlog(author) 
        returns (uint256, uint256, uint256) {
            
        return (authorToBlog[author].blockFirstPost, 
            authorToBlog[author].blockLatestPost,
            authorToBlog[author].postCount);
    }

    function post(string memory content) external onlyInitializedBlog(msg.sender) {
        BlogMetadata storage meta = authorToBlog[msg.sender];
        if(meta.postCount == 0) {
            meta.blockFirstPost = block.number;
        }
        meta.blockLatestPost = block.number;
        emit BlogPost(msg.sender, meta.postCount, content);
        meta.postCount += 1;
    }
}
