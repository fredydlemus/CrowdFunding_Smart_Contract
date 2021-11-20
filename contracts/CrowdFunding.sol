//SPDX-license-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    enum State {
        open,
        close,
        pause
    }

    struct Contribution {
        address contributor;
        uint256 value;
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable owner;
        State state;
        bool isFundeable;
        uint256 goal;
        uint256 totalFunded;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event stateChanged(State state, string id);
    event donation(
        string projectId,
        address donator,
        uint256 quantity,
        uint256 remaining
    );
    event projectCreated(
        string id,
        string name,
        string description,
        uint256 goal
    );

    modifier onlyOwner(uint256 projectIndex) {
        require(
            msg.sender == projects[projectIndex].owner,
            "You need to be the owner from this project to change the goal"
        );
        _;
    }

    modifier noOwner(uint256 projectIndex) {
        require(
            msg.sender != projects[projectIndex].owner,
            "you don't fund your own project"
        );
        _;
    }

    function createProject(
        string calldata _id,
        string calldata _name,
        string calldata _description,
        uint256 _goal
    ) public {
        require(_goal > 0, "Goal must be greater than 0");
        Project memory newProject = Project(
            _id,
            _name,
            _description,
            payable(msg.sender),
            State.open,
            true,
            _goal,
            0
        );
        projects.push(newProject);
        emit projectCreated(_id, _name, _description, _goal);
    }

    function fundProject(uint256 projectIndex)
        public
        payable
        noOwner(projectIndex)
    {
        Project memory project = projects[projectIndex];
        require(
            project.isFundeable,
            "Owner has decided to stop this fundraising for a while. Stay tuned "
        );

        require(
            project.totalFunded < project.goal,
            "Goal already achieved so you are not able to fund this anymore "
        );

        require(
            msg.value != uint256(0),
            "Please add some funds to contribute to project."
        );

        require(
            project.totalFunded + msg.value <= project.goal,
            "unable to add more fund, check amount remaining for our goal. "
        );

        project.owner.transfer(msg.value);
        project.totalFunded += msg.value;

        contributions[project.id].push(Contribution(msg.sender, msg.value));

        emit donation(
            project.id,
            msg.sender,
            msg.value,
            project.goal - project.totalFunded
        );
    }

    function changeProjectState(State newState, uint256 projectIndex)
        public
        onlyOwner(projectIndex)
    {
        Project memory project = projects[projectIndex];
        require(newState != project.state, "The new state must be different");
        project.state = newState;
        if (project.state == State.open) {
            project.isFundeable = true;
        } else {
            project.isFundeable = false;
        }

        emit stateChanged(project.state, project.id);
    }

    function viewGoal(uint256 projectIndex) public view returns (uint256) {
        return projects[projectIndex].goal;
    }

    function viewFunds(uint256 projectIndex) public view returns (uint256) {
        return projects[projectIndex].totalFunded;
    }

    function viewRemaining(uint256 projectIndex) public view returns (uint256) {
        uint256 remainingFunds = projects[projectIndex].goal -
            projects[projectIndex].totalFunded;
        return remainingFunds;
    }
}
