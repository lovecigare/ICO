//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    string public tokenName = "Golden Valley Venture";
    string public tokenSymbol = "GVV";

    uint256 public tokenTotalSupply = 1_000_000_000 * 10**18;

    address payable public owner;

    mapping(address => uint256) balances;

    constructor() ERC20(tokenName, tokenSymbol) {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function mint() public onlyOwner {
        _mint(msg.sender, tokenTotalSupply);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
