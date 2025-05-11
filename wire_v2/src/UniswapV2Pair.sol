// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import  "../lib/solmate/src/tokens/ERC20.sol";
import "../lib/solmate/src/utils/FixedPointMathLib.sol";
import "../lib/Math.sol";
import "../lib/solmate/src/utils/SafeTransferLib.sol";



error InsufficientLiquidityMinted();
interface IERC20 {
    function balanceOf(address account) external view returns(uint256);
    function Transfer(address to, uint256 amount) external returns(bool);
}
contract UniswapV2Pair is ERC20{
    // 父合约实现了构造函数，子合约必须实现
    constructor()ERC20("Uniswap V2","UNI-V2",18){

    }
    //事件
    event Mint(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event DebugLog(uint256 balance0, uint256 balance1, uint256 amount0, uint256 amount1, uint256 liquidity);
   // 池子里的token金额
    uint256 private reserve0;
    uint256 private reserve1;
    // 进来的token金额
    address public token0;
    address public token1;


    function init(address _token0, address _token1) external {
        require(token0==address(0)&&token1==address(0),"Aleardy init");
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to)external returns(uint256 liquidity){

        // 检查Token余额
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        // 计算dx dy
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        if (totalSupply == 0){
            // 如果是第一次添加流动性，直接mint
            // 最小流动性（MINIMUM_LIQUIDITY = 1000）被永久锁定在合约中，这是 Uniswap V2 的一个安全特性，用来：
            //防止第一个流动性提供者操纵价格
            //确保流动性池永远不会完全为空
            liquidity = FixedPointMathLib.sqrt(amount0 * amount1) - 1000;
            _mint(address(0), 1000); // 锁定最小流动性
        }else{
            liquidity =  Math.min(
                amount0 * totalSupply / reserve0,
                amount1 * totalSupply / reserve1
            );
        }

        // 添加调试日志
        emit DebugLog(balance0, balance1, amount0, amount1, liquidity);

       if (liquidity <= 0) revert InsufficientLiquidityMinted();
        // 给用户mint流动性 给LP Token
        _mint(to, liquidity);
        // 更新池子里的token金额
        reserve0 = balance0;
        reserve1 = balance1;
        emit Mint(msg.sender,amount0,amount1,to);
        return liquidity;
    }

    function burn(address to) external returns(uint256 amount0, uint256 amount1){
        // 检查token余额
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        // 计算流动性
        uint256 liquidity = balanceOf[address(this)];
        
        amount0 = liquidity * balance0 / totalSupply;
        amount1 = liquidity * balance1 / totalSupply;

        // 销毁流动性
        _burn(address(this), liquidity);
    
        // 转账给用户
        SafeTransferLib.safeTransfer(ERC20(token0), to, amount0);
        SafeTransferLib.safeTransfer(ERC20(token1), to, amount1);

        // 添加调试日志
        emit DebugLog(balance0, balance1, amount0, amount1, liquidity);
    }
}
