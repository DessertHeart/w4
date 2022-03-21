// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "./@openzeppelin/contracts/token/IERC20";

contract MyTokenMarket is  {

    // 交易对代币
    address myToken;
    address weth;
    
    // Router合约地址
    address router;
    
    constructor(address _myToken, address _weth, address _router) {
        myToken = _myToken;
        weth = _weth;
        router = _router;
    }

    // 添加MyToken与ETH流动池
    function addLiquidity(uint _myTokenNum, address _to, uint256 _amount) payable public {
       IERC20(myToken).transferFrom(msg.sender, router, _amount);
       IERC20(myToken).approve(router, _amount);
       
       IUniswapV2Router01(router).addLiquidityETH{value:msg.value}(
        mytoken,
        _myTokenNum,
         0,
         0,
        _to,
         block.timestamp
       );
    }
    
    // 购买MyToken
    function buyToken(uint256 _amount) payable public {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = myToken;

        IUniswapV2Router01(router).swapExactETHForTokens{value:msg.value}(
            0, 
            path, 
            msg.sender,
            block.timestamp
        )
    }

    // // 质押
    // function deposit() public {

    // }

    // // 提款
    // function withdraw() public {

    // }
}
