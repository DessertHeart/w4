// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./@openzeppelin/contracts/token/ERC20";

contract MyToken {
    constructor() ERC20("WETH", "WETH") {
        _mint(msg.sender, 100_0000);
    }
}
