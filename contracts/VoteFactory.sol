pragma solidity ^0.4.19;

import "./Ownable.sol";

contract VoteFactory is Ownable {
    modifier ownerOfVote(uint256 _voteId) {
        require(voteToOwner[_voteId] == msg.sender);
        _;
    }
    modifier stateOf(uint256 _voteId, State _state) {
        require(votes[_voteId].state == _state);
        _;
    }

    event CreateVote(uint256 id, string question, bytes32[] answers);
    event StartVote(uint256 id);
    event StopVote(uint256 id);

    enum State {
        Initial,
        Started,
        Stopped
    }

    uint256 constant MAX_VOTERS = 1e10;

    struct Vote {
        State state;
        string question;
        bytes32[] answers;
        address[] voters;
        
        mapping (uint256 => uint256) voterToAnswer;
    }

    Vote[] public votes;
    mapping (uint256 => address) public voteToOwner;
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
 /*   
    function createVote(string _question) external {
        uint256 voteId = votes.push(Vote(State.Initial, _question, new string[](0), new address[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        emit CreateVote(voteId, _question);
    }

    function addAnswer(uint256 _voteId, string _answer) external ownerOfVote(_voteId) {
        votes[_voteId].answers.push(_answer);
    }
*/    
    function createVote(string _question, bytes32[] _answers) external {
        uint256 voteId = votes.push(Vote(State.Initial, _question, _answers, new address[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        emit CreateVote(voteId, _question, _answers);
    }

    function voteAnswer(uint256 _voteId, uint256 _answerId) public view returns(bytes32) {
        return votes[_voteId].answers[_answerId];
    }
    
    function startVote(uint256 _voteId) external ownerOfVote(_voteId) {
        votes[_voteId].state = State.Started;
        emit StartVote(_voteId);
    }
    
    function stopVote(uint256 _voteId) external ownerOfVote(_voteId) stateOf(_voteId, State.Started) {
        votes[_voteId].state = State.Stopped;
        emit StopVote(_voteId);
    }

    function cast1(uint _voteId, uint _answerId) external stateOf(_voteId, State.Started) returns(uint256) {
        address[] storage voters = votes[_voteId].voters;

        require(voters.length < MAX_VOTERS, "Voters count must be lower MAX_VOTERS");

        for (uint i = 0; i < voters.length; i++)
            if (voters[i] == msg.sender) {
                _castVoter(_voteId, _answerId, i);
                return i;
            }

        uint voterId = votes[_voteId].voters.push(msg.sender) - 1;            
        _castVoter(_voteId, _answerId, voterId);
        return voterId;
    }

    function cast(uint256 _voteId, uint256 _answerId) external stateOf(_voteId, State.Started) returns(uint256) {
        require(votes[_voteId].voters.length < MAX_VOTERS, "Voters count must be lower MAX_VOTERS");

        uint256 voterId = getVoterId(_voteId);
        if (voterId < MAX_VOTERS) {
            _castVoter(_voteId, _answerId, voterId);
            return voterId;
        }

        voterId = votes[_voteId].voters.push(msg.sender) - 1;            
        _castVoter(_voteId, _answerId, voterId);
        return voterId;
    }

    function _castVoter(uint256 _voteId, uint256 _answerId, uint256 _voterId) private {
        votes[_voteId].voterToAnswer[_voterId] = _answerId;
    }

    function getVoterId(uint256 _voteId) public view returns(uint256) {
        address[] storage voters = votes[_voteId].voters;
        for (uint256 i = 0; i < voters.length; i++)
            if (voters[i] == msg.sender) {
                return i;
            }

        return MAX_VOTERS + 1;
    }

    function results(uint256 _voteId) public view returns(bytes32) {
        Vote storage vote = votes[_voteId];
        uint256[] memory result = new uint256[](vote.answers.length);

        for (uint256 i = 0; i < vote.voters.length; i++) {
            result[vote.voterToAnswer[i]]++;
        }

        uint256 maxId = 0;
        uint256 max = result[0];

        for (i = 0; i < result.length; i++) {
            if (result[i] > max) {
                maxId = i;
                max = result[i];
            }
        }

        return vote.answers[maxId];
    }

    function isStopped(uint256 _voteId) external view returns(bool) {
        return votes[_voteId].state == State.Stopped;
    }
    
}
