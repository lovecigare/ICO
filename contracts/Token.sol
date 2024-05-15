//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    string public tokenName = "Golden Valley Venture";
    string public tokenSymbol = "GVV";

    uint256 public tokenTotalSupply = 1_000_000_000 * 10 ** 18;

    address payable public owner;

    mapping(address => uint256) balances;

    constructor() ERC20(tokenName, tokenSymbol){
        _mint(msg.sender, tokenTotalSupply);
    }
}