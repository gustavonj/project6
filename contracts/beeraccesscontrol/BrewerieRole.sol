pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'BrewerieRole' to manage this role - add, remove, check
contract BrewerieRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event BrewerieAdded(address indexed account);
  event BrewerieRemoved(address indexed account);

  // Define a struct 'breweries' by inheriting from 'Roles' library, struct Role
  Roles.Role private breweries;

  // In the constructor make the address that deploys this contract the 1st brewerie
  constructor() public {
    _addBrewerie(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyBrewerie() {
    require(isBrewerie(msg.sender));
    _;
  }

  // Define a function 'isBrewerie' to check this role
  function isBrewerie(address account) public view returns (bool) {
    return breweries.has(account);
  }

  // Define a function 'addBrewerie' that adds this role
  function addBrewerie(address account) public onlyBrewerie {
    _addBrewerie(account);
  }

  // Define a function 'renounceBrewerie' to renounce this role
  function renounceBrewerie() public {
    _removeBrewerie(msg.sender);
  }

  // Define an internal function '_addBrewerie' to add this role, called by 'addBrewerie'
  function _addBrewerie(address account) internal {
    breweries.add(account);
    emit BrewerieAdded(account);
  }

  // Define an internal function '_removeBrewerie' to remove this role, called by 'renounceBrewerie'
  function _removeBrewerie(address account) internal {
    breweries.remove(account);
    emit BrewerieRemoved(account);
  }
}