// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenStaking {
    IERC20 public stakingToken;
    uint256 public constant REWARD_RATE = 15; // 15% reward rate
    uint256 public constant REWARD_DURATION = 180 days; // 6 months
    uint256 public constant MIN_LOCK_PERIOD = 30 days; // 1 month

    struct Staker {
        uint256 amount;
        uint256 rewardReleased;
        uint256 timeOfLastUpdate;
    }

    mapping(address => Staker) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(IERC20 _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        updateReward(msg.sender);

        if (stakers[msg.sender].amount == 0) {
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        }

        stakers[msg.sender].amount += _amount;
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0, "Cannot unstake 0 tokens");
        require(
            stakers[msg.sender].amount >= _amount,
            "Cannot unstake more than staked"
        );
        require(
            block.timestamp >=
                stakers[msg.sender].timeOfLastUpdate + MIN_LOCK_PERIOD,
            "Minimum lock period not met"
        );

        updateReward(msg.sender);
        stakers[msg.sender].amount -= _amount;
        stakingToken.transfer(msg.sender, _amount);
        emit Unstaked(msg.sender, _amount);
    }

    function claimReward() external {
        updateReward(msg.sender);
        uint256 reward = stakers[msg.sender].rewardReleased;
        stakers[msg.sender].rewardReleased = 0;
        stakingToken.transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    function updateReward(address _staker) internal {
        uint256 timeElapsed = block.timestamp - stakers[_staker].timeOfLastUpdate;
        uint256 reward = (stakers[_staker].amount * REWARD_RATE * timeElapsed) /
            (REWARD_DURATION * 100);
        stakers[_staker].rewardReleased += reward;
        stakers[_staker].timeOfLastUpdate = block.timestamp;
    }
}