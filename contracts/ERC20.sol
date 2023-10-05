// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    address owner;
    uint totalTokens;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint) {
        return 18;
    }

    function totalSupply() external view returns (uint) {
        return totalTokens;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(
        address to,
        uint amount
    ) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "not enough tokens!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    constructor(string memory _n, string memory _s, uint initialSupply) {
        _name = _n;
        _symbol = _s;
        owner = msg.sender;
        mint(initialSupply, owner);
    }

    function mint(uint amount, address _to) public onlyOwner {
        _beforeTokenTransfer(address(0), _to, amount);
        balances[_to] = amount;
        totalTokens += amount;
        emit Transfer(address(0), _to, amount);
    }

    function burn(address _from, uint amount) public onlyOwner {
        _beforeTokenTransfer(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
        emit Transfer(_from, address(0), amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}

    function _approve(
        address sender,
        address spender,
        uint amount
    ) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }
}
