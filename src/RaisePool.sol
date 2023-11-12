// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import "../lib/solady/src/auth/Ownable.sol";

/**
 * @title RaisePool
 * @author Zodomo.eth (Farcaster/Telegram/Discord/Github: @zodomo, X: @0xZodomo, Email: zodomo@proton.me)
 * @custom:github https://github.com/Zodomo/RaisePool
 */
contract RaisePool is Ownable {
    error Overflow();
    error Deadline();
    error Inactive();
    error TargetMet();
    error TargetNotMet();
    error TransferFailed();

    event Raise(address indexed sender, uint72 indexed amount);
    event Refund(address indexed sender, uint72 indexed amount);
    event Withdraw(uint72 indexed amount);
    event HardTargetReached();

    mapping(address => uint72) public amounts;
    uint72 public softTarget;
    uint72 public hardTarget;
    uint72 public raiseAmount;
    uint32 public deadline;
    bool public active;

    constructor(
        address _owner,
        uint32 _deadline,
        uint72 _softTarget,
        uint72 _hardTarget
    ) payable {
        if (_deadline <= block.timestamp) revert Deadline();
        _initializeOwner(_owner);
        if (msg.value > 0) {
            unchecked { amounts[msg.sender] += uint72(msg.value); }
        }
        softTarget = _softTarget;
        hardTarget = _hardTarget;
        deadline = _deadline;
        active = true; // Only change to false upon successful withdrawal to prevent further deposits
    }

    modifier isActive() {
        // Revert if inactive (raise paid) or hardTarget has been reached prior to raise() execution
        if (!active || raiseAmount + msg.value >= hardTarget) revert Inactive();
        _;
    }

    modifier isRefundable() {
        // Confirm deadline has been reached
        if (block.timestamp < deadline) revert Deadline();
        // Also confirm that the soft target hasn't been met
        if (raiseAmount >= softTarget) revert TargetMet();
        // If both states are true, refund deposit
        _;
    }

    modifier targetReached() {
        // Ensure at least soft target has been reached before allowing withdrawal
        if (raiseAmount < softTarget) revert TargetNotMet();
        _;
    }

    function raise() public payable isActive {
        if (msg.value > type(uint72).max) revert Overflow();
        uint72 raisedAmount = raiseAmount;
        if (raisedAmount + msg.value > hardTarget) {
            // Determine if raise exceeds hardTarget and refund overage
            uint72 overage;
            uint72 amount;
            unchecked {
                if (raisedAmount + msg.value > hardTarget) {
                    overage = (raisedAmount + uint72(msg.value)) - hardTarget;
                }
                amount = uint72(msg.value) - overage;
            }
            // Log adjusted raise
            unchecked {
                amounts[msg.sender] += amount;
                raiseAmount += amount;
            }
            (bool success, ) = payable(msg.sender).call{ value: overage }("");
            if (!success) { revert TransferFailed(); }
            emit Raise(msg.sender, amount);
            // Emit event here and prevent execution of code after if block to avoid duplicate storage read
            emit HardTargetReached();
            return; // Prevents execution of code after if block
        }
        // Log current raise
        unchecked {
            amounts[msg.sender] += uint72(msg.value);
            raiseAmount += uint72(msg.value);
        }
        emit Raise(msg.sender, uint72(msg.value));
    }

    function refund() external isRefundable {
        uint72 amount = uint72(amounts[msg.sender]);
        if (amount > 0) {
            delete amounts[msg.sender];
            unchecked { raiseAmount -= amount; }
            (bool success, ) = payable(msg.sender).call{ value: amount }("");
            if (!success) { revert TransferFailed(); }
            emit Refund(msg.sender, amount);
        }
    }

    function withdraw() external targetReached {
        uint72 amount = raiseAmount;
        unchecked { raiseAmount -= amount; }
        active = false;
        (bool success, ) = payable(owner()).call{ value: amount }("");
        if (!success) { revert TransferFailed(); }
        emit Withdraw(amount);
    }

    // Allow direct payments to be processed accordingly, no need to call raise() from etherscan
    receive() external payable { raise(); }
}
