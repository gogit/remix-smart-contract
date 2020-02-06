pragma solidity >=0.4.22 <0.7.0;

/** 
 * @title FundProposal
 * 
 */
contract FundProposal {
   
    struct Donor {
        address payable recipient;
        uint256 donated;    //donated amount   
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint donorCount; // number of accumulated donors
        uint256 donated; //donated amount 
        address proposer; 
    }

    address organizer;
    mapping(address => Donor) public donors;
    mapping(address => Proposal) public recipients;
    Proposal [] public proposals;
    
    /** 
     * 
     */
    constructor() public {
        organizer = msg.sender;
    }

    function registerProposal(string memory proposal_) public {
        Proposal memory proposal = Proposal({
            name: stringToBytes32(proposal_),
            donorCount: 0,
            donated: 0,
            proposer: msg.sender
        });
        
        proposals.push(proposal);
        recipients[msg.sender] = proposal;
    }
    
    function registerDonor(address payable recipient_) public {
        if(isValid(recipient_)){
            donors[msg.sender] = Donor({
                recipient: recipient_,
                donated: 0
            });
        }
    }
    
    function stringToBytes32(string memory input_) private pure returns (bytes32 result) {
        bytes memory emptyStringTest = bytes(input_);
        if (emptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(input_, 32))
        }
    }

    function isValid(address recipient_) view private returns(bool valid_) {
        for (uint p = 0; p < proposals.length; p++) {
            Proposal memory prop = proposals[p];
            if(prop.proposer == recipient_){
                valid_ = true;
                break;
            }
        }
    }
    
    receive() external payable   {
        Donor storage donor = donors[msg.sender];
        donor.donated = msg.value;
        recipients[donor.recipient].donated += msg.value; 
        recipients[donor.recipient].donorCount += 1;
        donor.recipient.transfer(msg.value);       
    }

    /** 
     * @return winningProposalIndex_
     */
    function winningProposal() public view
            returns (uint winningProposalIndex_)
    {
        Proposal memory winProp = proposals[0];
        uint winPropIndex = 0;
        for (uint p = 1; p < proposals.length; p++) {
            if (proposals[p].donated > winProp.donated) {
                winProp = proposals[p];
                winPropIndex = p;
            }
        }
        winningProposalIndex_ = winPropIndex;
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    function winnerAmount() public view
            returns (uint256 winnerAmount_)
    {
        winnerAmount_ = proposals[winningProposal()].donated;
    }
}
