//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6; 
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/90ed1af972299070f51bf4665a85da56ac4d355e/contracts/access/Ownable.sol";
pragma experimental ABIEncoderV2;
contract Voting is Ownable {

uint public proposalId=0;
struct Voter {
bool isRegistered;
bool hasVoted;
uint votedProposalId;
}

struct Proposal {
string description;
uint voteCount;
}

mapping (address => Voter) public _voterlist;
Proposal[] public _proposallist;
uint private _winningProposalId;

enum WorkflowStatus {
RegisteringVoters,
ProposalsRegistrationStarted,
ProposalsRegistrationEnded,
VotingSessionStarted,
VotingSessionEnded,
VotesTallied
}

WorkflowStatus public _workflow;

event VoterRegistered(address voterAddress);
event ProposalsRegistrationStarted();
event ProposalsRegistrationEnded();
event ProposalRegistered(uint proposalId);
event VotingSessionStarted();
event VotingSessionEnded();
event Voted (address voter, uint proposalId);
event VotesTallied();
event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus
newStatus);



function RegisterVoter(address _address) public onlyOwner {
       
        require(_workflow == WorkflowStatus.RegisteringVoters);
        require( _address != address(0),  "address is  0!");
        require(_voterlist[_address].isRegistered==false, " This address is already registered");
        _voterlist[_address].isRegistered=true;
        emit VoterRegistered(_address);
        
      }

function RegisterProposal(string memory _description) public {
        require(_workflow == WorkflowStatus.ProposalsRegistrationStarted);
        _proposallist.push(Proposal(_description,0));
         proposalId+= 1;
        emit ProposalRegistered(proposalId);
    }
    
    
    
function AddVote(uint _proposalId) public  {
        require(_workflow == WorkflowStatus.VotingSessionStarted);
        require(_voterlist[msg.sender].isRegistered==true, "The voter is not registered");
        require(_voterlist[msg.sender].hasVoted==false, "The voter has already voted");
        _voterlist[msg.sender].votedProposalId = _proposalId;
        _proposallist[_proposalId].voteCount += 1;
        _voterlist[msg.sender].hasVoted = true;
        emit Voted (msg.sender, _proposalId);
    }

function WinningProposal() public  onlyOwner {
    uint _winningVoteCount=0;
        
        require(_workflow == WorkflowStatus.VotingSessionEnded);
        for (uint i = 0; i < _proposallist.length; i++) {
            if (_proposallist[i].voteCount > _winningVoteCount) {
                _winningVoteCount = _proposallist[i].voteCount;
                _winningProposalId = i;
            }
        }

        _workflow = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
        emit VotesTallied();
        
        
    }

function Winner() public view returns (string memory, uint){
        require(_workflow == WorkflowStatus.VotesTallied, "Result is not ready!");
        return ( _proposallist[ _winningProposalId].description,_proposallist[ _winningProposalId].voteCount);
    }

function ProposalStart() public  onlyOwner {
        require(_workflow == WorkflowStatus.RegisteringVoters);
        _workflow = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
        emit ProposalsRegistrationStarted();
        
    }

function ProposalEnd() public onlyOwner {
        require(_workflow ==WorkflowStatus.ProposalsRegistrationStarted);
        _workflow=WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,WorkflowStatus.ProposalsRegistrationEnded);
        emit ProposalsRegistrationEnded();
       
    }



function VoteStart() public onlyOwner{
        require(_workflow == WorkflowStatus.ProposalsRegistrationEnded);
       _workflow = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
        emit VotingSessionStarted();
       
}

function VoteEnd() public onlyOwner {
        require(_workflow == WorkflowStatus.VotingSessionStarted);
        _workflow = WorkflowStatus.VotingSessionEnded;
         emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
         emit VotingSessionEnded ();
       
}
    

}




