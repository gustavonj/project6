pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'StoreRole' to manage this role - add, remove, check
contract StoreRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event StoreAdded(address indexed account);
  event StoreRemoved(address indexed account);

  // Define a struct 'stores' by inheriting from 'Roles' library, struct Role
  Roles.Role private stores;

  // In the constructor make the address that deploys this contract the 1st store
  constructor() public {
    _addStore(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyStore() {
    require(isStore(msg.sender));
    _;
  }

  // Define a function 'isStore' to check this role
  function isStore(address account) public view returns (bool) {
    return stores.has(account);
  }

  // Define a function 'addStore' that adds this role
  function addStore(address account) public onlyStore {
    _addStore(account);
  }

  // Define a function 'renounceStore' to renounce this role
  function renounceStore() public {
    _removeStore(msg.sender);
  }

  // Define an internal function '_addStore' to add this role, called by 'addStore'
  function _addStore(address account) internal {
    stores.add(account);
    emit StoreAdded(account);
  }

  // Define an internal function '_removeStore' to remove this role, called by 'renounceStore'
  function _removeStore(address account) internal {
    stores.remove(account);
    emit StoreRemoved(account);
  }
}