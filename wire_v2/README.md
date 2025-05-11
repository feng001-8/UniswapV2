# WIRE UNISWAP V2

## 简介

记录用foundry手搓uniswa_v2

## foundry 安装

Foundryup 是 Foundry 工具链的官方安装程序,运行 foundryup 将自动安装预编译二进制文件的最新稳定版本： forge 、 cast 、 anvil 和 chisel

```bash
curl -L https://foundry.paradigm.xyz | bash
```

## foundry 初始化

```bash
forge init
```

## foundry 编译

```bash
forge build
```

## 测试

### burn
时间点	User LP	Pair LP	Zero Addr LP	Total Supply
Mint后	9.999e17	0	1000	1e18
Transfer后	0	9.999e17	1000	1e18
Burn后	0	0	1000	1000
