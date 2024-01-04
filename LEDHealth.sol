// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LEDToken is ERC20 {
    uint256 public constant MAX_SUPPLY = 10_000_000_000 * 10**18; // Max supply of 10 billion tokens
    uint256 private constant REWARD_STEPS = 5000;
    uint256 private constant REWARD_SWIM_LENGTHS = 10;
    uint256 private constant REWARD_CALORIES = 100;

    mapping(address => uint256) public stepCount;
    mapping(address => uint256) public swimLengths;
    mapping(address => uint256) public caloriesBurnt;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTime;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount, uint256 timestamp);

    constructor() ERC20("LED Token", "LED") {
        // Mint initial tokens for the contract deployer
        _mint(msg.sender, MAX_SUPPLY);
    }

    // Record steps walked by the user and reward with tokens
    function recordSteps(uint256 _steps) external {
        stepCount[msg.sender] += _steps;
        uint256 tokensEarned = (_steps / REWARD_STEPS) * 10;
        _mint(msg.sender, tokensEarned * 10**18);
    }

    // Record lengths swam by the user and reward with tokens
    function recordSwimmingLengths(uint256 _lengths) external {
        swimLengths[msg.sender] += _lengths;
        uint256 tokensEarned = (_lengths / REWARD_SWIM_LENGTHS) * 10;
        _mint(msg.sender, tokensEarned * 10**18);
    }

    // Track calorie burn and reward with tokens
    function recordCaloriesBurnt(uint256 _calories) external {
        caloriesBurnt[msg.sender] += _calories;
        uint256 tokensEarned = (_calories / REWARD_CALORIES) * 10;
        _mint(msg.sender, tokensEarned * 10**18);
    }

    // Allow users to stake LED tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Must stake a non-zero amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Transfer tokens from the user to the contract
        _transfer(msg.sender, address(this), amount);

        // Update staked balance and staking timestamp
        stakedBalance[msg.sender] += amount;
        stakingTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount, block.timestamp);
    }

    // Allow users to unstake previously staked tokens and receive rewards
    function unstake(uint256 amount) external {
        require(amount > 0, "Must unstake a non-zero amount");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        // Calculate rewards based on staking duration
        uint256 stakedTime = block.timestamp - stakingTime[msg.sender];
        uint256 rewards = (stakedTime * stakedBalance[msg.sender]) / 1000;

        // Transfer staked tokens back to the user along with rewards
        stakedBalance[msg.sender] -= amount;
        stakingTime[msg.sender] = block.timestamp;

        // Transfer tokens including rewards
        _transfer(address(this), msg.sender, amount + rewards);

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    // Mint new tokens (only callable by the contract owner)
    function mint(uint256 amount) external {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(msg.sender, amount);
    }

    // Burn tokens from the caller's balance
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
