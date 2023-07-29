// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Author: Mike Attara

contract CrowdFund {
    uint256 public goal;
    uint256 public deadline;
    uint256 public raisedAmount = 0;
    address public beneficiary;
    address public owner;
    mapping(address => uint256) public contributions;

    event Contribution(address _contributor, uint256 _amount);
    event Refund(address _contributor, uint256 _amount);
    event Withdrawal(address _beneficiary, uint256 _amount);

    constructor(
        uint256 _goal,
        uint256 _deadline,
        address _beneficiary
    ) payable {
        goal = _goal;
        deadline = _deadline;
        beneficiary = _beneficiary;
        owner = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(raisedAmount < goal, "Goal has been reached");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit Contribution(msg.sender, msg.value);
    }

    function getRefund() public {
        require(block.timestamp > deadline, "Deadline has not passed");
        require(raisedAmount < goal, "Goal has been reached");

        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        raisedAmount -= amount;

        emit Refund(msg.sender, amount);
    }

    function withdraw() public {
        require(
            msg.sender == owner || msg.sender == beneficiary,
            "You aren't the owner or beneficiary"
        );
        require(raisedAmount >= goal, "Goal has not been reached");

        emit Withdrawal(beneficiary, raisedAmount);

        payable(beneficiary).transfer(raisedAmount);
    }

    function getAmountRaised() public view returns (uint256) {
        return raisedAmount;
    }

    function getDeadline() public view returns (uint256) {
        return deadline;
    }

    function getGoal() public view returns (uint256) {
        return goal;
    }

    function getBeneficiary() public view returns (address) {
        return beneficiary;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getContribution(
        address _contributor
    ) public view returns (uint256) {
        return contributions[_contributor];
    }

    function getAllContributors() public view returns (address[] memory) {
        address[] memory contributors = new address[](raisedAmount);
        for (uint256 i = 0; i < raisedAmount; i++) {
            contributors[i] = msg.sender;
        }
        return contributors;
    }
}
