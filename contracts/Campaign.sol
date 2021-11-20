pragma solidity >=0.7.0 <0.9.0;

contract CampaignFactory {
    Campaign[] public deployedCampaigns;

    function createCampaign(uint256 minium) public {
        Campaign campaign = new Campaign(minium, msg.sender);

        deployedCampaigns.push(campaign);
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approveVoteCount;
        mapping(address => bool) approveVotes;
    }

    address public manager;
    uint256 public miniumContribution;
    mapping(address => bool) public approvers;
    uint256 public numRequest;
    uint256 public approverCount;
    mapping(uint256 => Request) public requests;

    constructor(uint256 minum, address sender) {
        manager = sender;
        miniumContribution = minum;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function contribute() public payable {
        require(msg.value > miniumContribution);

        approvers[msg.sender] = true;
        approverCount++;
    }

    function createRequest(
        uint256 value,
        address payable recipient,
        string memory description
    ) public restricted {
        uint256 requestIndex = numRequest++;
        Request storage request = requests[requestIndex];
        request.description = description;
        request.value = value;
        request.recipient = recipient;
        request.complete = false;
        request.approveVoteCount = 0;
    }

    function approve(uint256 index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approveVotes[msg.sender]);

        request.approveVotes[msg.sender] = true;
        request.approveVoteCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(request.approveVoteCount > (approverCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
