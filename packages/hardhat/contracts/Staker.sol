// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;
  
  event Stake(address staker, uint256 amount);

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(! exampleExternalContract.completed(), "The staking is already completed !");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    require(msg.value > 0, "The staking amount has to be positive.");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

  function execute() public notCompleted{
    require(block.timestamp > deadline, "The deadline is not reached yet !");
    if (balances[msg.sender] >= threshold) {
      exampleExternalContract.complete{value: balances[msg.sender]}();
    }
    else {
      openForWithdraw = true;
    }
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256){
    return block.timestamp < deadline ? deadline - block.timestamp : 0;
  }

  function withdraw() public notCompleted{
    require(openForWithdraw, "It is not possible to withdraw.");
    (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
    require(sent, "Failed to send Ether");
    balances[msg.sender] = 0;

  }
  // Add the `receive()` special function that receives eth and calls stake()

  receive() external payable {
    stake();
  }

}
