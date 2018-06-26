pragma solidity ^0.4.17;

contract ownedContract {
  address public owner;

  constructor () public {
    owner = msg.sender;
  }

  function transferContrac(address newOwner) public ownerOnly{
    owner = newOwner;
  }

  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }
}

contract timedContract {

  uint256 public deadline;

  constructor(uint256 _deadline) public {
    deadline = block.timestamp + _deadline * 1 minutes;
  }

  modifier onlyWhenOpen{
    require(block.timestamp <= deadline);
    _;
  }

  modifier onlyWhenClosed{
    require(block.timestamp > deadline);
    _;
  }
}

interface token {
  function transfer(address to, uint256 amount) external;
}

contract Crowdsale is ownedContract,timedContract {
  address public beneficiary;
  uint256 public goal;
  uint256 public raised;
  uint256 public tokenPrice;
  token public tokenUsed;
  uint256 public totalTokens;
  uint256 public tokensLeft;

  mapping(address => uint256) balanceOf;

  bool public goalReached = false;

  event GoalReached(address reciever, uint256 amount);
  event FundTransfer(address from, uint256 amount, bool isContribution);

  constructor(uint256 _tokenPrice,
              address _benficiary,
              token _token,
              uint256 _deadline,
              uint256 _totalTokens,
              uint256 _goal) public timedContract(_deadline){
    require(_tokenPrice > 0);
    require(_benficiary != address(0));
    require(_token != address(0));
    // require(_deadline >= block.timestamp);
    require(_totalTokens > 0);
    require(_goal > 0);

    tokenPrice = _tokenPrice;
    beneficiary = _benficiary;
    tokenUsed = _token;
    totalTokens = _totalTokens;
    tokensLeft = _totalTokens;
    goal = _goal;
    deadline = _deadline * 1 minutes + block.timestamp;
    raised = 0;
  }

  function () public payable onlyWhenOpen {
    uint256 amount = msg.value;
    address to = msg.sender;
    require(amount*tokenPrice <= tokensLeft);
    sendTokens(to, amount);
    raised += amount;
    tokensLeft -= amount * tokenPrice;
    if(raised == goal){
        goalReached = true;
        emit GoalReached(beneficiary,amount);
    }
    emit FundTransfer(msg.sender, amount, true);
  }

  function sendTokens(address _to, uint256 _amount) internal {
    tokenUsed.transfer(_to, _amount*tokenPrice);
  }

  function withdrawFunds() public ownerOnly {
    address(beneficiary).transfer(address(this).balance);
  }

  function isClosed () public view returns (bool){
     return deadline < block.timestamp;
  }

  function time () public view returns(uint256){
      return block.timestamp;
  }


}
