// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {RaisePool} from "../src/RaisePool.sol";

contract RaisePoolTest is Test {
    RaisePool public pool;

    receive() external payable {}
}
