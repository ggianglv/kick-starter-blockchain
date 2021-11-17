pragma solidity >=0.7.0 <0.9.0;

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approveVoteCount;
        mapping(address => bool) approveVotes;
    }
    
    address public manager;
    uint public miniumContribution;
    mapping(address => bool) public approvers;
    uint public numRequest;
    mapping (uint => Request) requests;
    
    constructor(uint minum) {
        manager = msg.sender;
        miniumContribution = minum;
    }
    
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function contribute() public payable {
        require(msg.value > miniumContribution);
        
        approvers[msg.sender] = true;
    }
    
    function createRequest (uint value, address payable recipient, string memory description) public restricted {
        uint requestIndex = numRequest++;
        Request storage request = requests[requestIndex];
        request.description = description;
        request.value = value;
        request.recipient = recipient;
        request.complete = false;
        request.approveVoteCount = 0;
    }
    
    function approve (uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approveVotes[msg.sender]);
        
        request.approveVotes[msg.sender] = true;
        request.approveVoteCount++;
    }
    
    function getRequest (uint index) internal view returns (Request storage r) {
        Request storage request = requests[index];
        
        return request;
    }
}