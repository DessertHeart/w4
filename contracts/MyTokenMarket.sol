// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}

contract MyTokenMarket {

    // 交易对代币
    address private immutable myToken;
    address private immutable weth;
    
    // Router合约地址
    address private immutable router;

    // MasterChef合约地址
    address private immutable masterChef;

    // index of pool
    uint256 private immutable pid;

    // 余额查询
    mapping(address => uint256) userBalance;
    
    constructor(
        address _myToken, 
        address _weth, 
        address _router,
        address _masterChef,
        uint256 _pid
        ) 
    {
        myToken = _myToken;
        weth = _weth;
        router = _router;
        masterChef = _masterChef;
        pid = _pid;
    }

    // 添加MyToken与ETH流动池
    function addLiquidity(uint _myTokenNum, address _to) payable public returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(myToken).transferFrom(msg.sender, address(this), _myTokenNum);
        IERC20(myToken).approve(router, _myTokenNum);
       
        (amountToken, amountETH, liquidity) = IUniswapV2Router01(router).addLiquidityETH{value:msg.value}(myToken, _myTokenNum, 0, 0, _to, block.timestamp);
        // 退回
        if(amountToken < _myTokenNum) {
            IERC20(myToken).transferFrom(address(this), msg.sender, _myTokenNum - amountToken);
        }else if(amountETH < msg.value){
            address(this).call{value: msg.value - amountETH}("");
        }
    }
    
    // 购买MyToken
    function buyToken(address _to) payable public {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = myToken;

        IUniswapV2Router01(router).swapExactETHForTokens{value:msg.value}(
            0, 
            path, 
            _to,
            block.timestamp
        );  
    }

    // 质押
    function deposit(address _to) payable public returns(uint256[] memory amount) {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = myToken;
        amount = IUniswapV2Router01(router).swapExactETHForTokens{value:msg.value}(
            0, 
            path, 
            _to,
            block.timestamp
        ); 
        // 多退
        if(amount[0] < msg.value){
            address(this).call{value: msg.value - amount[0]}("");
        }
        IERC20(myToken).approve(masterChef, amount[1]);
        IMasterChef(masterChef).deposit(pid, amount[1]);
        userBalance[_to] = amount[1];

        return amount;
    }

    // 提款
    function withdraw(address _to) public returns(bool){
        require(msg.sender == _to, "Wrong guys");
        uint256 amount = userBalance[_to];
        userBalance[_to] = 0;
        IMasterChef(masterChef).withdraw(pid, amount);

        return true;
    }
}
