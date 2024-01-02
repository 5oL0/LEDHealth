// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract LEDHealth is ERC20, ERC20Permit {
    string private welcomeMessage;
    uint8 private _decimals;

    mapping(address => uint256) public stepCount; // Mapping to track steps for each user
    mapping(address => uint256) public swimLengths; // Mapping to track swimming lengths for each user
    mapping(address => uint256) public caloriesBurnt; // Mapping to track calories burnt for each user
    mapping(address => mapping(string => bool)) public unlockedAchievements; // Mapping to unlock achievements for each user
    mapping(address => uint256) public stakedBalance; // Mapping to track staked balances
    mapping(address => uint256) public stakingTime; // Mapping to track staking time

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount, uint256 timestamp);

    constructor() ERC20("LED Token", "LED") ERC20Permit("LED Token") {
        _mint(msg.sender, 1000000000000 * 10**decimals()); // Mint initial tokens for the contract deployer
        welcomeMessage = "Greetings LED Token Users!";
        _decimals = 18; // Set the number of decimals for the token
    }

    function getMessage() public view returns (string memory) {
        return welcomeMessage;
    }

    function setMessage(string memory _msg) public {
        welcomeMessage = _msg;
    }

    // Function to record steps walked by the user
    function recordSteps(uint256 _steps) public {
        stepCount[msg.sender] += _steps;

        // For every 5000 steps, reward the user with 100 LED Tokens
        uint256 tokensEarned = (_steps / 5000) * 10;
        _mint(msg.sender, tokensEarned * 10**_decimals);
    }

    // Function to record lengths swam by the user
    function recordSwimmingLengths(uint256 _lengths) public {
        swimLengths[msg.sender] += _lengths;

        // For every 10 lengths, reward the user with 100 LED Tokens
        uint256 tokensEarned = (_lengths / 10) * 10;
        _mint(msg.sender, tokensEarned * 10**_decimals);
    }

    // Function to track calorie burn, since it involves fitness
    function recordCaloriesBurnt(uint256 _calories) public {
        caloriesBurnt[msg.sender] += _calories;

        // For every 100 calories burnt, reward the user with 50 LED Tokens
        uint256 tokensEarned = (_calories / 100) * 10;
        _mint(msg.sender, tokensEarned * 10**_decimals);
    }

    // Function to reward users for reaching specific milestones or achievements
    function unlockAchievement(string memory _achievement, uint256 _rewardTokens) public {
        require(!unlockedAchievements[msg.sender][_achievement], "Achievement already unlocked");

        unlockedAchievements[msg.sender][_achievement] = true;
        _mint(msg.sender, _rewardTokens * 10**_decimals);
    }

    // Function to allow users to stake LED tokens
    function stake(uint256 amount) public {
        require(amount > 0, "Must stake a non-zero amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Transfer tokens from the user to the contract
        _transfer(msg.sender, address(this), amount);

        // Update staked balance and staking timestamp
        stakedBalance[msg.sender] += amount;
        stakingTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount, block.timestamp);
    }

    // Function to allow users to unstake previously staked tokens
    function unstake(uint256 amount) public {
        require(amount > 0, "Must unstake a non-zero amount");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        // Calculate rewards based on staking duration
        uint256 stakedTime = block.timestamp - stakingTime[msg.sender];
        uint256 rewards = (stakedTime * stakedBalance[msg.sender]) / 1000; // Modify this calculation

        // Transfer staked tokens back to the user along with rewards
        stakedBalance[msg.sender] -= amount;
        stakingTime[msg.sender] = block.timestamp;

        // Transfer tokens including rewards
        _transfer(address(this), msg.sender, amount + rewards);

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    // Function to get the number of decimals of the token
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}