// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

// >>>>>>>>>>>> [ IMPORTS ] <<<<<<<<<<<<

import "../lib/solady/src/auth/Ownable.sol";
import "../lib/SocialCredits/src/ISocialCredits.sol";
import "../lib/solady/src/utils/FixedPointMathLib.sol";

/**
 * @title RaisePool
 * @notice This is a contract that facilitates a raise for a good cause and distributes GOODPERSON tokens to donators.
 * @author Zodomo.eth (Farcaster/Telegram/Discord/Github: @zodomo, X: @0xZodomo, Email: zodomo@proton.me)
 * @custom:github https://github.com/Zodomo/RaisePool
 */
contract RaisePool is Ownable {

    // >>>>>>>>>>>> [ ERRORS ] <<<<<<<<<<<<

    error Overflow();
    error Deadline();
    error Inactive();
    error TargetMet();
    error TargetNotMet();
    error TransferFailed();

    // >>>>>>>>>>>> [ EVENTS ] <<<<<<<<<<<<

    event Raise(address indexed sender, uint96 indexed amount);
    event Refund(address indexed sender, uint96 indexed amount);
    event Withdraw(uint96 indexed amount);
    event HardTargetReached();

    // >>>>>>>>>>>> [ STORAGE VARIABLES ] <<<<<<<<<<<<

    mapping(address => uint96) public amounts;
    mapping(address => uint256) public incentives;
    address public incentiveToken;
    uint96 public raiseAmount;
    uint96 public softTarget;
    uint96 public hardTarget;
    uint40 public deadline;
    bool public active;
    

    // >>>>>>>>>>>> [ MODIFIERS ] <<<<<<<<<<<<

    /// @dev Revert call if raise has concluded
    modifier isActive() {
        // Revert if inactive (raise paid) or hardTarget has been reached prior to raise() execution
        if (!active) revert Inactive();
        _;
    }

    /// @dev Revert call if deadline hasn't been reached or raise passed soft target
    modifier isRefundable() {
        // Confirm deadline has been reached
        if (block.timestamp < deadline) revert Deadline();
        // Also confirm that the soft target hasn't been met
        if (raiseAmount >= softTarget) revert TargetMet();
        // If both states are true, refund deposit
        _;
    }

    /// @dev Revert call if soft target was not reached
    modifier targetReached() {
        // Ensure at least soft target has been reached before allowing withdrawal
        if (raiseAmount < softTarget) revert TargetNotMet();
        _;
    }

    // >>>>>>>>>>>> [ CONSTRUCTOR ] <<<<<<<<<<<<

    constructor(
        address _owner,
        address _incentiveToken,
        uint40 _deadline,
        uint96 _softTarget,
        uint96 _hardTarget
    ) payable {
        if (_deadline <= block.timestamp) revert Deadline();
        _initializeOwner(_owner);
        incentiveToken = _incentiveToken;
        if (msg.value > 0) {
            unchecked { amounts[msg.sender] += uint96(msg.value); }
        }
        softTarget = _softTarget;
        hardTarget = _hardTarget;
        deadline = _deadline;
        active = true; // Only change to false upon successful withdrawal to prevent further deposits
    }

    // >>>>>>>>>>>> [ PUBLIC FUNCTIONS ] <<<<<<<<<<<<

    /// @notice Process a raise payment and issue incentive token
    /// @dev Only reverts once target has been met, last TX is allowed to overpay and will be refunded
    function raise() public payable isActive {
        if (msg.value > type(uint96).max) revert Overflow();
        uint96 amount = uint96(msg.value);
        uint96 raisedAmount = raiseAmount;
        if (raisedAmount == hardTarget) revert TargetMet();
        // If raise meets or exceeds hardTarget, process and close raise
        if (raisedAmount + msg.value >= hardTarget) {
            // Determine if raise exceeds hardTarget and calculate overage
            uint96 overage;
            unchecked {
                if (raisedAmount + msg.value > hardTarget) {
                    overage = (raisedAmount + uint96(msg.value)) - hardTarget;
                }
                amount = uint96(msg.value) - overage;
            }
            // Process overage refund, if any
            if (overage > 0) {
                (bool success, ) = payable(msg.sender).call{ value: overage }("");
                if (!success) { revert TransferFailed(); }
            }
            emit HardTargetReached();
        }
        // Otherwise, process normal raise
        unchecked {
            amounts[msg.sender] += amount;
            raiseAmount += amount;
        }
        emit Raise(msg.sender, amount);
        // Mint incentive token if configured
        address token = incentiveToken;
        if (token != address(0)) {
            uint256 allocation = ISocialCredits(token).getAllocation(address(this));
            uint256 mint = FixedPointMathLib.fullMulDiv(amount, allocation, hardTarget);
            unchecked { incentives[msg.sender] += mint; }
            ISocialCredits(token).mint(msg.sender, mint);
        }
    }

    /// @notice Process refund if soft target isn't reached by deadline
    /// @dev Burns SocialCredits allocation before returning ETH
    function refund() external isRefundable {
        // Cache amount to save gas
        uint96 amount = uint96(amounts[msg.sender]);
        if (amount > 0) {
            // Forfeit incentive token if configured
            address token = incentiveToken;
            if (token != address(0)) {
                // Forfeit all issued SocialCredits and purge state
                ISocialCredits(incentiveToken).forfeit(msg.sender, incentives[msg.sender]);
                delete incentives[msg.sender];
            }
            delete amounts[msg.sender];
            unchecked { raiseAmount -= amount; }
            // Process refund
            (bool success, ) = payable(msg.sender).call{ value: amount }("");
            if (!success) { revert TransferFailed(); }
            emit Refund(msg.sender, amount);
        }
    }

    /// @notice Process withdrawal at any point after soft target is reached and lock contract
    function withdraw() external targetReached {
        // Adjust state
        uint96 amount = raiseAmount;
        unchecked { raiseAmount -= amount; }
        active = false;
        // Process withdrawal
        (bool success, ) = payable(owner()).call{ value: amount }("");
        if (!success) { revert TransferFailed(); }
        emit Withdraw(amount);
    }

    /// @notice Allow direct payments to be processed accordingly, no need to call raise() from etherscan
    receive() external payable { raise(); }
}
