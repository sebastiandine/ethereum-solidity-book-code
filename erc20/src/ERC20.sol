// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {

    string public name;
    string public symbol;

    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address=>uint256) private ownerToBalance;
    mapping(address=>mapping(address=>uint256)) private ownerToSpenderToValue;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        ownerToBalance[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return ownerToBalance[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "Sender does not have enough funds.");
        ownerToBalance[msg.sender] -= value;
        ownerToBalance[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf(from) >= value, "Owner does not have enough funds.");
        require(allowance(from, msg.sender) >= value, "Sender's allowance is not large enough.");
        ownerToBalance[from] -= value;
        ownerToBalance[to] += value;
        ownerToSpenderToValue[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        ownerToSpenderToValue[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return ownerToSpenderToValue[owner][spender];
    }

}
