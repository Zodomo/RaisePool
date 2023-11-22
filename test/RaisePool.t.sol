// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {RaisePool} from "../src/RaisePool.sol";
import {SocialCredits} from "../lib/SocialCredits/src/SocialCredits.sol";

contract RaisePoolTest is Test {
    RaisePool public pool;
    SocialCredits public token;

    receive() external payable {}

    function setUp() public {
        token = new SocialCredits("Zodomo's Social Credits", "ZSC", 1_000_000_000 ether, address(this));
        pool = new RaisePool(address(this), address(token), uint40(block.timestamp + 24 hours), 10 ether, 20 ether);
        token.allocate(address(pool), 50_000_000 ether);
        vm.deal(address(this), 20 ether);
    }

    function testRaise() public {
        pool.raise{ value: 1 ether }();
        require(token.balanceOf(address(this)) == 2_500_000 ether, "incentive mint amount error");
        require(address(pool).balance == 1 ether, "pool balance error");
        pool.raise{ value: 1 ether }();
        require(token.balanceOf(address(this)) == 5_000_000 ether, "incentive mint amount error");
        require(address(pool).balance == 2 ether, "pool balance error");
    }

    function testRefund() public {
        pool.raise{ value: 1 ether }();
        vm.warp(block.timestamp + 25 hours);
        uint256 balance = address(this).balance;
        token.approve(address(pool), type(uint256).max);
        pool.refund();
        require(address(this).balance == balance + 1 ether, "refund balance error");
        require(address(pool).balance == 0, "pool balance error");
        require(token.balanceOf(address(this)) == 0, "token balance error");
    }

    function testWithdraw() public {
        pool.raise{ value: 15 ether }();
        vm.warp(block.timestamp + 25 hours);
        uint256 balance = address(this).balance;
        pool.withdraw();
        require(address(this).balance == balance + 15 ether, "withdraw balance error");
        require(address(pool).balance == 0, "pool balance error");
        require(token.balanceOf(address(this)) == 37_500_000 ether, "token balance error");
    }
}
