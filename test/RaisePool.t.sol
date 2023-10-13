// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {RaisePool} from "../src/RaisePool.sol";

contract RaisePoolTest is Test {
    RaisePool public pool;

    receive() external payable {}

    function setUp() public {
        vm.deal(address(this), 100 ether);
        pool = new RaisePool(address(4200069), 2 ether, block.timestamp + 60);
    }

    function testDirectPayment() public {
        (bool success, ) = payable(address(pool)).call{ value: 2 ether }("");
        if (!success) { revert(); }
    }
    function testMultiplePayments() public {
        (bool success, ) = payable(address(pool)).call{ value: 0.5 ether }("");
        if (!success) { revert(); }
        (success, ) = payable(address(pool)).call{ value: 0.5 ether }("");
        if (!success) { revert(); }
        (success, ) = payable(address(pool)).call{ value: 0.5 ether }("");
        if (!success) { revert(); }
        (success, ) = payable(address(pool)).call{ value: 0.5 ether }("");
        if (!success) { revert(); }
    }

    function testOverpaymentRebate() public {
        uint256 balance = address(781364987).balance;
        vm.deal(address(781364987), 3 ether);
        vm.prank(address(781364987));
        (bool success, ) = payable(address(pool)).call{ value: 2 ether }("");
        if (!success) { revert(); }
        require(address(pool).balance == 2 ether, "pool balance error");
        require(address(781364987).balance == balance + 1 ether, "sender balance error");
    }

    function testWithdraw() public {
        (bool success, ) = payable(address(pool)).call{ value: 2 ether }("");
        if (!success) { revert(); }
        uint256 balance = address(4200069).balance;
        pool.withdraw();
        balance = address(4200069).balance - balance;
        require(balance == 2 ether, "withdraw error");
    }

    function testRefund() public {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(address(pool)).call{ value: 2 ether }("");
        if (!success) { revert(); }
        vm.warp(block.timestamp + 61);
        pool.refund();
        require(address(pool).balance == 0, "refund error");
        require(address(this).balance == balance, "sender balance error");
    }

    function testInactive() public {
        (bool success, ) = payable(address(pool)).call{ value: 2 ether }("");
        if (!success) { revert(); }
        pool.withdraw();
        vm.expectRevert(RaisePool.Inactive.selector);
        pool.raise{ value: 1 ether }();
    }
}
