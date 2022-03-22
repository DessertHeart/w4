// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "./@openzeppelin/contracts/token/IERC20";
import "./IMiniChefV2.sol";
import "./IRewarder.sol";

contract MyTokenMarket is  {

    // 交易对代币
    address myToken;
    address weth;
    
    // Router合约地址
    address router;

    // MasterChef合约地址
    address miniChef

    // index of pool
    uint256 pid = IERC20(myToken).length -1;
    
    constructor(
        address _myToken, 
        address _weth, 
        address _router,
        address _miniChef
        ) 
    {
        myToken = _myToken;
        weth = _weth;
        router = _router;
        miniChef = _miniChef;
    }

    // 添加MyToken与ETH流动池
    function addLiquidity(uint _myTokenNum, address _to, uint256 _amount) payable public {
       IERC20(myToken).transferFrom(msg.sender, address(this), _amount);
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

    // 质押：应该是输入LP代币的地址？
    function deposit(uint256 _lpamount, address _rewarder) public {

        // 添加pool
        IMiniChefV2(miniChef).add(1, IERC20(myToken), IRewarder(_rewarder));

        IERC20(myToken).transferFrom(msg.sender, address(this), _lpamount);
        IERC20(myToken).approve(miniChef, _lpamount);
        
        IMiniChefV2(miniChef).deposit(pid, _lpamount, msg.sender);
    }

    // 提款
    function withdraw(uint256 _lpamount) public {
        IERC20(myToken).transferFrom(msg.sender, address(this), _amount);
        IERC20(myToken).approve(miniChef, _amount);

        IMiniChefV2(miniChef).withdraw(pid, _lpamount, msg.sender)
    }
}
