// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/JpegSniper/FlatLaunchpeg.sol";

contract HackTest is Test {
    FlatLaunchpeg public flatLaunchpeg;
    Hack public hack;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        flatLaunchpeg = new FlatLaunchpeg(69, 5, 5);
    }

    function testAttack() public {
        vm.prank(attacker);
        hack = new Hack(address(flatLaunchpeg));
        vm.stopPrank();
        assertEq(flatLaunchpeg.totalSupply(), 69);
        assertEq(flatLaunchpeg.balanceOf(attacker), 69);
    }
}
