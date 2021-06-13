pragma solidity ^0.6.0;
// This allows us to return an array of structs from a function
pragma experimental ABIEncoderV2;

contract Wallet {
    // Define a list of approvers
    address[] public approvers;
    // Define quorum (number of approvers you need to approve transfers)
    uint public quorum;
    // Define data structure of transfers
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }
    
    // Container to hold transfers
    Transfer[] public transfers;
    
    // Define mapping to record who approved transfers 
    mapping(address => mapping(uint => bool)) public approvals;
    
    // Give initial values of variables in constructor
    constructor(address[] memory _approvers, uint _quorum) public {
        approvers = _approvers;
        quorum = _quorum;
    }
    
    // Create functions to return the entire array
    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }
    
    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }
    
    // Create function for creating transfers
    function createTransfer(uint amount, address payable to) external onlyApprover {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
        ));
    }
    
    // Function to approve tranfers
    function approveTransfer(uint id) external onlyApprover {
        require(transfers[id].sent == false, "transfer has been already sent");
        require(approvals[msg.sender][id] == false, "cannot approve current transfer twice");
        
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        
        if(transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
    }
    
    // Function to receive Ether
    receive() external payable {}
    
    // Access control
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "only approver allowed");
        _;
    }
}
