// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/UniswapV2Pair.sol";
import  "../lib/solmate/src/tokens/ERC20.sol";
import "forge-std/Test.sol";

contract ERC20Mock is ERC20{
    constructor(string memory _name,string memory _symbol,uint8 _decimals) 
        ERC20(_name,_symbol,_decimals)
    {}

    function mint(uint256 _amount) external{
        _mint(msg.sender,_amount);
    }
}

contract UniwapV2PairTest is Test{
    UniswapV2Pair pair;
    ERC20Mock  mockToken0;
    ERC20Mock  mockToken1;

    function setUp() public{
        mockToken0 = new ERC20Mock("Token0","T0",18);
        mockToken1 = new ERC20Mock("Token1","T1",18);
        pair = new UniswapV2Pair();
        pair.init(address(mockToken0),address(mockToken1));

        mockToken0.mint(10 ether);
        mockToken1.mint(10 ether);
    }

    function testMint() public{
        mockToken0.transfer(address(pair),1 ether);
        mockToken1.transfer(address(pair),1 ether);

        pair.mint(address(this));
        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertEq(pair.totalSupply(), 1 ether);
    }

    function testburn() public {
        mockToken0.transfer(address(pair),1 ether);
        mockToken1.transfer(address(pair),1 ether);
        // 添加流动性
        pair.mint(address(this));

        // 转移LP token给pair
        pair.transfer(address(pair), pair.balanceOf(address(this)));
        // 销毁流动性
        (uint256 amount0,uint256 amount1) = pair.burn(address(this));
        assertEq(amount0, 1 ether-1000);
        assertEq(amount1, 1 ether-1000);
        assertEq(pair.totalSupply(), 1000);
        assertEq(mockToken0.balanceOf(address(this)), 10 ether -1000);
        assertEq(mockToken1.balanceOf(address(this)), 10 ether -1000);
    }


        function testTwoburn() public {
        mockToken0.transfer(address(pair),1 ether);
        mockToken1.transfer(address(pair),1 ether);
        // 添加流动性
        pair.mint(address(this));

        mockToken0.transfer(address(pair),1 ether);
        mockToken1.transfer(address(pair),2 ether);
        // 添加流动性
        pair.mint(address(this));
        // 转移LP token给pair
        pair.transfer(address(pair), pair.balanceOf(address(this)));
        // 销毁流动性
        (uint256 amount0,uint256 amount1) = pair.burn(address(this));
        assertEq(amount0, 2 ether-1000);
        // 添加流动性的比例不同
        assertEq(amount1, 3 ether-1500);
        assertEq(pair.totalSupply(), 1000);
        assertEq(mockToken0.balanceOf(address(this)), 10 ether -1000);
        assertEq(mockToken1.balanceOf(address(this)), 10 ether -1500); 
    }



    function testSwap() public {
        mockToken0.transfer(address(pair),1 ether);
        mockToken1.transfer(address(pair),2 ether);
        // 添加流动性
        pair.mint(address(this));

        // 转账给pair
        mockToken0.transfer(address(pair), 1 ether);

        // 交换
        pair.swap(address(this), 0, 0.997 ether );
        assertEq(mockToken0.balanceOf(address(this)), 10 ether -1 ether - 1 ether);
        assertEq(mockToken1.balanceOf(address(this)), 10 ether -2 ether +  0.997 ether);
    }

}