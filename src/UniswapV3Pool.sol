pragma solidity ^0.8.14;
import {Tick} from "../src/lib/Tick.sol";
import {Position} from "../src/lib/Position.sol";

contract UniswapV3Pool {
    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    // pool tokens , immutable
    address public immutable token0;
    address public immutable token1;

    // Packing variables that are read together;
    struct Slot0 {
        // Current sqrt(P)
        uint160 sqrtPriceX96;
        // Current tick
        int24 tick;
    }

    Slot0 public slot0;
    // Amount of liquidity,L.
    uint128 public liquidity;

    // Ticks Info
    mapping(int24 => Tick.Info) public ticks;
    // Position Info
    mapping(bytes32 => Position.Info) public positions;


    constructor(
        address token0_,
     address token1_,
        uint160 sqrtPriceX96,
        int24 tick
    ){
        token0 = token0_;
        token1 = token1_;
        // todo
        slot0 = Slot0({sqrtPriceX96: sqrtPriceX96, tick:tick});

    }

    function mint(
        address owner; // token 所有者的地址，来识别是谁提供的流动性
        int24 lowerTick;
        int24 upperTick;
        uint128 amount; // 用户希望提供的流动性的数量
    ) external returns(uint256 amount0, uint256 amount1) {
        /// 用户指定价格区间和流动性的数量
        /// 合约更新 ticks 和 positions 的mapping
        /// 合约计算出用户需要提供的token数量
        /// 合约从用户处获得token，并且验证数量是否正确

        if(
            lowerTick >= upperTick ||
            lowerTick < MIN_TICK ||
            upperTick > MAX_TICK
        ) revert InvalidTickRange();

        if(amount == 0) revert ZeroLiquidity();
        ticks.update(lowerTick, amount); // todo
        ticks.update(upperTick, amount);

        Position.Info storage position = position.get( // todo
            owner,
            lowerTick,
            upperTick
        );
        position.update(amount);// todo
    }

}