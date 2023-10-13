// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import "solady/src/auth/Ownable.sol";

contract RaisePool is Ownable {
    error TargetMet();
    error TargetNotMet();
    error TransferFailed();
    error DeadlineNotReached();

    event Raise(address _sender, uint256 _amount);
    event Refund(address _sender, uint256 _amount);
    event Reached();
    event Withdraw();

    uint256 public immutable target;
    uint256 public immutable deadline;
    mapping(address => uint256) public amounts;

    constructor(
        address _owner,
        uint256 _target,
        uint256 _deadline
    ) payable {
        _initializeOwner(_owner);
        if (msg.value > 0) {
            unchecked { amounts[msg.sender] += msg.value; }
        }
        target = _target;
        deadline = _deadline;
    }

    function raise() public payable {
        if (address(this).balance - msg.value >= target) { revert TargetMet(); }
        uint256 overage;
        if (address(this).balance > target) {
            unchecked { overage = address(this).balance - target; }
            (bool success, ) = payable(msg.sender).call{ value: overage }("");
            if (!success) { revert TransferFailed(); }
            unchecked { amounts[msg.sender] += msg.value - overage; }
            emit Raise(msg.sender, msg.value - overage);
            emit Reached();
            return;
        }
        unchecked { amounts[msg.sender] += msg.value; }
        emit Raise(msg.sender, msg.value);
    }

    function refund() external {
        if (block.timestamp < deadline) { revert DeadlineNotReached(); }
        uint256 amount = amounts[msg.sender];
        if (amount > 0) {
            delete amounts[msg.sender];
            (bool success, ) = payable(msg.sender).call{ value: amount }("");
            if (!success) { revert TransferFailed(); }
            emit Refund(msg.sender, amount);
        }
    }

    function withdraw() external {
        if (address(this).balance != target) { revert TargetNotMet(); }
        (bool success, ) = payable(owner()).call{ value: address(this).balance }("");
        if (!success) { revert TransferFailed(); }
        emit Withdraw();
    }

    receive() external payable { raise(); }
}
