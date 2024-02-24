// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract SimpleStakingSketch {
    struct StakeInfo {
        uint256 unitsAmount;
        uint256 depositTime;
        address staker;
    }
    struct StakerInfo {
        uint256[] stakes;
        uint256 exitTime;
    }
    uint256 public totalEthStaked;
    uint256 public currentStakeNum;
    uint256 public constant UNIT = 1e17; // 0.1 ETH
    uint256 public constant STAKE_UNITS = 50; // 5 ETH
    uint256 public constant EXIT_PERIOD = 1 minutes;
    uint256 public constant APR = 3; // 3% Annual Percentage Rate
    mapping(uint256 => StakeInfo) public stakes;
    mapping(address => StakerInfo) public stakers;
    mapping(uint256 => address) public poSBlocks;
    uint256 public currentPoSBlock;


    // function to stake an amount of ether
    function depositStake() public payable {
        require(
            stakers[msg.sender].exitTime == 0,
            "cannot deposit stake while exiting"
        );
        require(msg.value == STAKE_UNITS * UNIT, "need to provide 5 ETH");
        stakes[currentStakeNum] = StakeInfo(
            STAKE_UNITS,
            block.timestamp,
            msg.sender
        );
        stakers[msg.sender].stakes.push(currentStakeNum);
        totalEthStaked += msg.value;
        currentStakeNum++;
    }

    function exit() public {
        require(stakers[msg.sender].exitTime == 0, "not starting a new exit");
        require(
            stakers[msg.sender].stakes.length > 0,
            "to exit you need some stake"
        );
        // give time for slashing proofs:
        stakers[msg.sender].exitTime = block.timestamp + EXIT_PERIOD;
    }

    // function to withdraw the staked amount
    function withdraw() public {
        require(
            stakers[msg.sender].exitTime > block.timestamp,
            "No enough exit time"
        );
        uint256 amountToWithdraw;
        for (uint256 i = 0; i < stakers[msg.sender].stakes.length; i++) {
            uint256 stakeNum = stakers[msg.sender].stakes[i];
            uint256 stakePeriod = block.timestamp -
                stakes[stakeNum].depositTime -
                EXIT_PERIOD;
            uint256 _unitsAmount = stakes[stakeNum].unitsAmount;
            uint256 stakeReward = ((_unitsAmount * UNIT * APR) /
                (365 days * 100)) * stakePeriod;
            amountToWithdraw =
                amountToWithdraw +
                _unitsAmount *
                UNIT +
                stakeReward;
            totalEthStaked -= stakes[stakeNum].unitsAmount * UNIT;
            stakes[stakeNum].unitsAmount = 0;
        }
        stakers[msg.sender].exitTime = 0; // allow future stakes
        payable(msg.sender).transfer(amountToWithdraw);
    }

    // function to slash a target if providing a valid proof
    function slash(address target, uint256 proof) public {
        if (proof < 4) {
            // simulates checking a proof of invalid behaviour
            // If proof is OK, slash a unit (0.1 Eth)
            for (uint256 i = 0; i < stakers[target].stakes.length; i++) {
                uint256 stakeNum = stakers[target].stakes[i];
                if (stakes[stakeNum].unitsAmount > 0) {
                    stakes[stakeNum].unitsAmount--;
                    totalEthStaked -= UNIT;
                    payable(msg.sender).transfer(UNIT);
                    break;
                }
            }
        }
    }

    function stakeLotery() public {
        // bytes32 seed = blockhash(block.number - 1); // For blockchain
        // For testing in Remix:
        bytes32 seed = 0x1122334455667788990011223344556677889900112233445566778899001122;
        while (true) {
            bytes32 randomForSelectedStake = keccak256(abi.encodePacked(seed));
            bytes32 randomForLoteryWin = keccak256(
                abi.encodePacked(randomForSelectedStake)
            );
            uint256 selectedStakeNum = uint256(randomForSelectedStake) %
                currentStakeNum;
            uint256 _unitsAmount = stakes[selectedStakeNum].unitsAmount;
            console.log("currentStakeNum %s", currentStakeNum);
            console.log("selectedStakeNum %s", selectedStakeNum);
            console.log("randomForLoteryWin %s", uint256(randomForLoteryWin));
            bool win = _unitsAmount > uint256(randomForLoteryWin) % STAKE_UNITS;
            if (win) {
                poSBlocks[currentPoSBlock] = stakes[selectedStakeNum].staker; // set winner
                currentPoSBlock++;
                break;
            }
            seed = randomForSelectedStake;
        }
    }

    receive() external payable {} // To fund the APR for staking rewards
}
