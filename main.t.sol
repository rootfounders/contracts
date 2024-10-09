// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "./main.sol";

contract NewTopicTest is Test {
    Ponopo public ponopo;

    function setUp() public {
        ponopo = new Ponopo();
    }

    function testPack() public {
        uint48 result = ponopo.pack(uint32(12), uint16(20));
        uint32 first;
        uint16 second;
        (first, second) = ponopo.unpack(result);
        assertEq(first, 12);
        assertEq(second, 20);
    }

    function testNewTopic() public {
        uint256 topicId = ponopo.createTopic();
        assertEq(topicId, 1);
    }

    function testNewSubtopic() public {
        uint256 subtopicId = ponopo.createSubtopic(1);
        assertEq(subtopicId, ponopo.pack(1, 1));
    }

    function testNewSubtopicNoAccess() public {
        vm.expectRevert();
        ponopo.createSubtopic(2);
    }

    // function testPublish() public {
    //     Record record = {
    //     };
    //     ponopo.publish(
    //         ponopo.pack(1, 1),
    //         record
    //     );
    // }
}