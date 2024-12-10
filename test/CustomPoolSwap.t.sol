// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Import Uniswap V3 Core contracts using the correct paths
import "v3-core/contracts/UniswapV3Factory.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "v3-core/contracts/libraries/PoolAddress.sol";


// OpenZeppelin ERC20 implementation
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Import Foundry's test library
import "forge-std/Test.sol";

contract MyCustomToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**18);  // Mint 1 million tokens
    }
}

contract CustomPoolSwap is Test {
    MyCustomToken public tokenA;
    MyCustomToken public tokenB;
    UniswapV3Factory public factory;
    IUniswapV3Pool public pool;

    function setUp() public {
        // Deploy two custom ERC20 tokens
        tokenA = new MyCustomToken("Token A", "TKA");
        tokenB = new MyCustomToken("Token B", "TKB");

        // Deploy the Uniswap V3 Factory contract
        factory = new UniswapV3Factory();

        // Create the pool with a fee of 0.3% (3000)
        factory.createPool(address(tokenA), address(tokenB), 3000);

        // Get the pool address
        address poolAddress = factory.getPool(address(tokenA), address(tokenB), 3000);
        pool = IUniswapV3Pool(poolAddress);
    }

    function testSwap() public {
        uint256 amountToSwap = 1000 * 10**18; // Define the amount to swap (e.g., 1000 tokens)

        // Approve the pool to spend tokens
        tokenA.approve(address(pool), amountToSwap);

        // Perform the token swap (true indicates tokenA to tokenB, false is the opposite)
        // The 0 value for `sqrtPriceLimitX96` means no price limit
        pool.swap(
            address(this),  // The address performing the swap
            true,           // TokenA -> TokenB
            int256(amountToSwap),  // Amount to swap (positive for exact input swap)
            0,              // No price limit (price range for the swap)
            ""              // No additional data
        );

        // Ensure the swap was successful by checking the balance of TokenB after swap
        uint256 balanceAfter = tokenB.balanceOf(address(this));
        assert(balanceAfter > 0);  // Ensure we have received tokens after the swap
    }
}
