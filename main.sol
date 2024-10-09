// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.27;

// type projectId is uint;

enum DetailsLocationType {
    IPNS
}

struct Project {
    uint id;
    address owner;
    DetailsLocationType detailsLocationType;
    string detailsLocation;
    string shortName;
}

struct Tip {
    address from;
    uint projectId;
    uint value;
    address token;
}

contract RootFounders {
    event Tipped(address indexed from, address indexed to, uint value, address indexed token);
    event Commented(address indexed from, uint indexed projectId);

    uint private projectCounter;

    // TODO: should these be private??? What about automatic getters?
    mapping(uint => Project) private projectsById;
    mapping(address => uint[]) private projectsByOwner;
    mapping(uint => Tip[]) private tipsByProjectId;

    function createProject(DetailsLocationType detailsLocationType, string memory detailsLocation, string memory shortName) public returns (uint id) {
        // 62 bytes is the length of IPNS name
        require(bytes(detailsLocation).length >= 62, "detailsLocation should be at least 62 bytes long");
        require(bytes(shortName).length > 0, "shortName is required");

        id = projectCounter ++;

        Project storage newProject = projectsById[id];
        newProject.id = id;
        newProject.owner = msg.sender;
        newProject.detailsLocationType = detailsLocationType;
        newProject.detailsLocation = detailsLocation;
        newProject.shortName = shortName;

        uint[] storage projects = projectsByOwner[msg.sender];
        projects.push(id);
    }
}