// migrating the appropriate contracts
var BrewerieRole = artifacts.require("./BrewerieRole.sol");
var DistributorRole = artifacts.require("./DistributorRole.sol");
var StoreRole = artifacts.require("./StoreRole.sol");
var ConsumerRole = artifacts.require("./ConsumerRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(BrewerieRole);
  deployer.deploy(DistributorRole);
  deployer.deploy(StoreRole);
  deployer.deploy(ConsumerRole);
  deployer.deploy(SupplyChain);
};
