// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {RootFounders, DetailsLocationType, Project} from "../src/main.sol";
import "openzeppelin-contracts/contracts/finance/PaymentSplitter.sol";

contract MainContractTest is Test {
    RootFounders public rootFounders;

    function setUp() public {
        rootFounders = new RootFounders();
    }

    function test_createProject() public {
        uint expectedId = 0;
        vm.expectEmit(true, true, true, true);
        emit RootFounders.ProjectCreated(expectedId, address(this));

        uint id = rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "test project");
        assertEq(id, expectedId);

        Project memory project = rootFounders.getProject(id);
        assertEq(project.id, id);
        assertTrue(project.detailsLocationType == DetailsLocationType.IPNS);
        assertEq(project.detailsLocation, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8");
        assertEq(project.shortName, "test project");

    }

    function test_createProjectInvalid() public {
        vm.expectRevert("detailsLocation should be at least 62 bytes long");
        rootFounders.createProject(DetailsLocationType.IPNS, "wrong", "test project");

        vm.expectRevert("shortName is required");
        rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "");
    }

    receive() external payable {}

    // TODO: test it with another contract, so that we can check balances
    function test_tip() public {
        uint id = rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "test project");
        Project memory project = rootFounders.getProject(id);

        vm.expectEmit(true, true, true, true);
        emit PaymentSplitter.PaymentReceived(address(this), 1000000000000000000);
        (bool success, ) = address(project.tipJar).call{value: 1000000000000000000}("");

        assertTrue(success);
    }

    function test_comment() public {
        uint id = rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "test comment project");

        // vm.startSnapshotGas("comment");
        rootFounders.comment(id, "whoa such a nice project! whoa such a nice project! whoa such a nice project! whoa such a nice project! whoa such a nice project! ");
    }

    function test_addTeammate() public {
        uint id = rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "test project");

        vm.expectRevert("account did not apply to join team");
        rootFounders.addTeammate(id, address(1));

        rootFounders.applyTo(id);

        vm.expectEmit(true, true, true, true);
        emit RootFounders.JoinedTeam(id, address(this));

        rootFounders.addTeammate(id, address(this));
        address[] memory team = rootFounders.team(id);

        assertEq(team.length, 1);
        assertEq(team[0], address(this));
    }

     function test_removeTeammate() public {
        uint id = rootFounders.createProject(DetailsLocationType.IPNS, "k51qzi5uqu5dlvj2baxnqndepeb86cbk3ng7n3i46uzyxzyqj2xjonzllnv0v8", "test project");

        rootFounders.applyTo(id);
        rootFounders.addTeammate(id, address(this));

        vm.expectEmit(true, true, true, true);
        emit RootFounders.LeftTeam(id, address(this));

        rootFounders.removeTeammate(id, address(this));

        address[] memory team = rootFounders.team(id);
        assertEq(team.length, 0);
    }
}
