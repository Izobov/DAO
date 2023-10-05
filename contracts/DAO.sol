// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';

contract DAO {
    IERC20 public  token;

    struct ProposalVote {
        uint aggainstVotes;
        uint forVotes;
        uint abstainVotes;
        mapping (address => bool) hasVoted;
    }

    struct Proposal {
        uint votingStarts;
        uint votingEnds;
        bool executed;
    }

    mapping (bytes32 => Proposal) public  proposals;
    mapping (bytes32 => ProposalVote) public  proposalVotes;
    uint public constant VOTING_DELAY = 10;
    uint public  constant VOTING_DURATION = 60;
   
    enum ProposalState {Pending, Active, Succeseded, Defeated, Executed}

    constructor(IERC20 _token) {
        token = _token;
    }

    function propose(
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        string calldata _description
    ) external returns (bytes32){
        require(token.balanceOf(msg.sender) > 1, "not enough token");

        bytes32 proposalId = generateProposalId(_to, _value, _func, _data, keccak256(bytes(_description))); 
        require(proposals[proposalId].votingStarts == 0, "proposal already exists");
        proposals[proposalId] = Proposal({
            votingStarts: block.timestamp + VOTING_DELAY, 
            votingEnds: block.timestamp + VOTING_DELAY + VOTING_DURATION,
            executed: false
        });
        return  proposalId;
    }

    function vote (bytes32 proposalId, uint8 voteType) external {
        require(state(proposalId)== ProposalState.Active, "not active");

        uint votingPower = token.balanceOf(msg.sender);
        require(votingPower > 0, "not enough tokens");
        ProposalVote storage proposalVote = proposalVotes[proposalId];

        require(!proposalVote.hasVoted[msg.sender], "already voted");
        if (voteType == 0) {
            proposalVote.aggainstVotes += votingPower;
        } else if(voteType == 1) {
            proposalVote.forVotes += votingPower;
        } else {
            proposalVote.abstainVotes += votingPower;
        }

        proposalVote.hasVoted[msg.sender] = true;

    }

    function state(bytes32 proposalId) public view returns (ProposalState) {
        Proposal storage p = proposals[proposalId];
        ProposalVote storage v = proposalVotes[proposalId];
        require(p.votingStarts > 0, "proposal doesen't exist" );
        if (p.executed) {
            return  ProposalState.Executed;
        }

        if (block.timestamp < p.votingStarts) {
            return  ProposalState.Pending;
        }

        if (block.timestamp >= p.votingStarts && block.timestamp < p.votingEnds) {
            return  ProposalState.Active;
        }

        if (v.forVotes > v.aggainstVotes) {
            return  ProposalState.Succeseded;
        } else {
            return  ProposalState.Defeated;
        }
    }

    function execute (
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        bytes32 _descriptionHash
    ) external returns (bytes memory)  {
        bytes32 proposalId = generateProposalId(_to, _value, _func, _data, _descriptionHash);
        require(state(proposalId) == ProposalState.Succeseded, "invalid state");
        Proposal storage p = proposals[proposalId];
        p.executed = true;

        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            data = _data;
        }
       (bool s, bytes memory res) = _to.call{value: _value}(data);

       require(s, "tx faild");

       return res;
        
    }

    function generateProposalId (address _to, uint _value, string calldata _func, bytes calldata _data, bytes32  _desc) private pure returns (bytes32) {
        return keccak256(abi.encode(_to, _value, _func, _data, _desc));
    }
}