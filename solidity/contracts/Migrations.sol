pragma solidity ^0.4.11;

import './resolver/ResolverClient.sol';
import './ownership/HasNoFunds.sol';

contract Migrations is ResolverClient, HasNoFunds {
  address public owner;
  uint256 public last_completed_migration;

  function Migrations(address _resolver) ResolverClient(_resolver)
  {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public
  onlyOwner
  {
    last_completed_migration = completed;
  }

  function upgrade(address new_address)
  onlyOwner
  {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
