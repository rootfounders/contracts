// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

import "openzeppelin-contracts/contracts/finance/PaymentSplitter.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

enum DetailsLocationType {
    IPFS
}

struct Project {
    uint id;
    address owner;
    DetailsLocationType detailsLocationType;
    string detailsLocation;
    string shortName;

    // TODO: subclass to emit proper events with projectId, ERC20 tokens included (custom tip(IERC20 token) func)
    PaymentSplitter tipJar;
}

contract RootFounders is Ownable {
    event Received(address, uint);
    event Fallback(address, uint);

    event ProjectCreated(uint indexed id, address indexed owner, Project project);
    // event Tipped(address indexed from, uint indexed to, uint value, address indexed token);
    event Commented(address indexed from, uint indexed projectId, string comment);
    event PostedUpdate(uint indexed projectId, string comment);
    event Applied(uint indexed projectId, address indexed who);
    event JoinedTeam(uint indexed projectId, address indexed who);
    event LeftTeam(uint indexed projectId, address indexed who);

    uint private projectCounter;

    mapping(uint => Project) internal projectById;
    mapping(address => uint[]) internal projectsByOwner;
    // mapping(uint => Tip[]) internal tipsByProjectId;

    // Applying and teams
    mapping(uint => EnumerableSet.AddressSet) applicantsByProjectId;
    mapping(uint => EnumerableSet.AddressSet) teamsByProjectId;

    modifier onlyProjectOwner(uint projectId) {
        Project memory project = projectById[projectId];
        require(
            msg.sender == project.owner,
            "Only project owner can call this function."
        );
        _;
    }

    receive() external payable { emit Received(msg.sender, msg.value); }
    fallback() external payable { emit Fallback(msg.sender, msg.value); }
    function withdraw(uint256 amount) public onlyOwner() {
        require(amount <= address(this).balance, "exceeded current balance");
        payable(msg.sender).transfer(amount);
    }

    function createProject(DetailsLocationType detailsLocationType, string memory detailsLocation, string memory shortName) public returns (uint id) {
        // 34 bytes is the length of IPFS name, 62 bytes would be the length of IPNS name
        require(bytes(detailsLocation).length >= 34, "detailsLocation should be at least 34 bytes long");
        require(bytes(shortName).length > 0, "shortName is required");

        id = projectCounter ++;

        Project storage newProject = projectById[id];
        newProject.id = id;
        newProject.owner = msg.sender;
        newProject.detailsLocationType = detailsLocationType;
        newProject.detailsLocation = detailsLocation;
        newProject.shortName = shortName;

        address[] memory payees = new address[](1);
        payees[0] = msg.sender;
        // payees[1] = address(this);

        uint256[] memory shares = new uint256[](1);
        shares[0] = 100;
        // shares[1] = 0;
        newProject.tipJar = new PaymentSplitter(payees, shares);

        uint[] storage projects = projectsByOwner[msg.sender];
        projects.push(id);

        emit ProjectCreated(id, msg.sender, newProject);
    }

    // TODO: updateProject
    // TODO: updateProjectShortName
    // TODO: deleteProject

    function getProject(uint id) public view returns (Project memory project) {
        project = projectById[id];
        require(project.owner != address(0), "project not found");
    }

    function getProjectTipJar(uint id) public view returns (address tipJar) {
        Project memory project = getProject(id);
        tipJar = address(project.tipJar);
    }

    function comment(uint id, string calldata content) public {
        getProject(id);
        require(bytes(content).length > 0, "comment text required (calldata)");

        emit Commented(msg.sender, id, content);
    }

    function postUpdate(uint id, string calldata content) public onlyProjectOwner(id) {
        getProject(id);
        require(bytes(content).length > 0, "update text required (calldata)");

        emit PostedUpdate(id, content);
    }

    function applyTo(uint projectId) public returns (bool) {
        getProject(projectId);
        if (EnumerableSet.add(applicantsByProjectId[projectId], msg.sender)) {
            emit Applied(projectId, msg.sender);
            return true;
        }
        return false;
    }

    function addTeammate(uint projectId, address mate) public onlyProjectOwner(projectId) {
        require(mate != address(0), "teammate address required");
        getProject(projectId);

        require(EnumerableSet.contains(applicantsByProjectId[projectId], mate), "account did not apply to join team");

        if (EnumerableSet.add(teamsByProjectId[projectId], mate)) {
            EnumerableSet.remove(applicantsByProjectId[projectId], mate);
            emit JoinedTeam(projectId, mate);
        }
    }

    function removeTeammate(uint projectId, address mate) public onlyProjectOwner(projectId) {
        require(mate != address(0), "teammate address required");
        getProject(projectId);

        if (EnumerableSet.remove(teamsByProjectId[projectId], mate)) {
            emit LeftTeam(projectId, mate);
        }
    }

    function teammateRemoveSelf(uint projectId) public {
        getProject(projectId);
        if (EnumerableSet.remove(teamsByProjectId[projectId], msg.sender)) {
            emit LeftTeam(projectId, msg.sender);
        }
    }

    function team(uint projectId) public view returns (address[] memory addresses) {
        getProject(projectId);

        addresses = EnumerableSet.values(teamsByProjectId[projectId]);
    }
}