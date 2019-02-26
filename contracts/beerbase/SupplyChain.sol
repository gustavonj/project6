pragma solidity ^0.4.24;

import "../beeraccesscontrol/ConsumerRole.sol";
import "../beeraccesscontrol/StoreRole.sol";
import "../beeraccesscontrol/DistributorRole.sol";
import "../beeraccesscontrol/BrewerieRole.sol";
import "../beercore/Ownable.sol";


// Define a contract 'Supplychain'
contract SupplyChain is ConsumerRole, StoreRole, DistributorRole, BrewerieRole, Ownable {

  // Define 'owner'
  //address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Brewed,           // 0
    Bottled,          // 1
    Packaged,         // 2
    Sold,             // 3
    EnabledForOrder,  // 4
    Ordered,          // 5
    Shipped,          // 6
    Received,         // 7
    ForSale,          // 8
    Purchased        // 9
  }

  State constant defaultState = State.Brewed;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Brewerie, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originBrewerieID; // Metamask-Ethereum address of the Brewerie
    string  originBrewerieName; // Brewerie Name
    string  originBrewerieInformation;  // Brewerie Information
    string  originBrewerieLatitude; // Brewerie Latitude
    string  originBrewerieLongitude;  // Brewerie Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    string  productStyle; // Product Style
    uint    alcoholTax; // Alcohol Tax
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address storeID; // Metamask-Ethereum address of the Store
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Brewed(uint upc);
  event Bottled(uint upc);
  event Packaged(uint upc);
  event Sold(uint upc);
  event EnabledForOrder(uint upc);
  event Ordered(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event ForSale(uint upc);
  event Purchased(uint upc);
  
  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner());
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

   // Define a modifer that checks to see if msg.sender == Brewerie
  modifier onlyItemBrewerie (uint _upc) {
    require(msg.sender == items[_upc].originBrewerieID); 
    _;
  }

  modifier onlyItemDistributor (uint _upc) {
    require(msg.sender == items[_upc].distributorID); 
    _;
  }

  modifier onlyItemStore (uint _upc) {
    require(msg.sender == items[_upc].storeID); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Brewed
  modifier brewed(uint _upc) {
    require(items[_upc].itemState == State.Brewed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Bottled
  modifier bottled(uint _upc) {
    require(items[_upc].itemState == State.Bottled);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Packaged
  modifier packaged(uint _upc) {
    require(items[_upc].itemState == State.Packaged);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is EnabledForOrder
  modifier enabledForOrder(uint _upc) {
    require(items[_upc].itemState == State.EnabledForOrder);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Ordered
  modifier ordered(uint _upc) {
    require(items[_upc].itemState == State.Ordered);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased);
    _;
  }

  
  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    //owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public onlyOwner {
    selfdestruct(owner());
  }

  // Define a function 'brewsItem' that allows a brewerie to mark an item 'Brewed'
  function brewsItem(uint _upc, address _originBrewerieID, string _originBrewerieName, string _originBrewerieInformation, string  _originBrewerieLatitude, string  _originBrewerieLongitude, string  _productNotes, string _productStyle, uint _alcoholTax) public 
  {
    // Add the new item as part of Brew
    items[_upc] = Item({
        sku: sku, 
        upc: _upc, 
        ownerID: _originBrewerieID,
        originBrewerieID: _originBrewerieID,
        originBrewerieName: _originBrewerieName,
        originBrewerieInformation: _originBrewerieInformation,
        originBrewerieLatitude: _originBrewerieLatitude,
        originBrewerieLongitude: _originBrewerieLongitude,
        productID: _upc + sku,
        productNotes: _productNotes,
        productStyle: _productStyle,
        alcoholTax: _alcoholTax,
        productPrice: 0,
        itemState: defaultState,
        distributorID: address(0),
        storeID: address(0),
        consumerID: address(0)
    });

    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Brewed(_upc);
    }

  // Define a function 'bottleUp' that allows a brewerie to mark an item 'Packed'
  function bottleUp(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  brewed(_upc)
  // Call modifier to verify caller of this function
  onlyItemBrewerie(_upc)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Bottled;
    
    // Emit the appropriate event
    emit Bottled(_upc);
  }


  // Define a function 'packagingItem' that allows a brewerie to mark an item 'Packaged'
  function packagingItem(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  bottled(_upc)
  // Call modifier to verify caller of this function
  onlyItemBrewerie(_upc)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Packaged;
    items[_upc].productPrice = _price;
    
    // Emit the appropriate event
    emit Packaged(_upc);
  }

  // Define a function 'buyPackageItem' that allows a distributor to mark an item 'Ordered'
  function buyPackageItem(uint _upc) public payable
  // Call modifier to check if upc has passed previous supply chain stage
  packaged(_upc)  
  // Call modifer to check if buyer has paid enough
  paidEnough(items[_upc].productPrice)
  // Call modifier to check value
  checkValue(_upc)
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Sold;
    items[_upc].ownerID = msg.sender;
    items[_upc].distributorID = msg.sender; 

     // Transfer money to brewerie
    items[_upc].originBrewerieID.transfer(items[_upc].productPrice);    

    // Emit the appropriate event
    emit Sold(_upc);
    
  }

  function enableForOrder(uint _upc, uint _price) public
    // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc)  
    // Call modifier to verify caller of this function
    onlyItemDistributor(_upc)
    {
    // Update the appropriate fields
    items[_upc].itemState = State.EnabledForOrder;
    items[_upc].productPrice = _price;
    // Emit the appropriate event
    emit EnabledForOrder(_upc);
    
  }

  function orderItem(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
    enabledForOrder(_upc)  
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifier to check value
    checkValue(_upc)
    {
    // Update the appropriate fields
    items[_upc].itemState = State.Ordered;
    items[_upc].ownerID = msg.sender;
    items[_upc].storeID = msg.sender; 

    // Transfer money to distributor
    items[_upc].distributorID.transfer(items[_upc].productPrice);    

    // Emit the appropriate event
    emit Ordered(_upc);
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    ordered(_upc)  
    // Call modifier to verify caller of this function
    onlyItemDistributor(_upc)
    {
    // Update the appropriate fields
    items[_upc].itemState = State.Shipped;
    // Emit the appropriate event
    emit Shipped(_upc);
    
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
    shipped(_upc)  
    // Access Control List enforced by calling Smart Contract / DApp
    onlyItemStore(_upc)
    {
    // Update the appropriate fields - ownerID, retailerID, itemState
    items[_upc].itemState = State.Received;
    // Emit the appropriate event
    emit Received(_upc);
    
  }


  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Sold'
  // Use the above modifiers to check if the item is received
  function putsItemOnSale(uint _upc, uint _price) public 
    // Call modifier to check if upc has passed previous supply chain stage
    received(_upc)  
    // Access Control List enforced by calling Smart Contract / DApp
    onlyItemStore(_upc)
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;
    // Emit the appropriate event
    emit ForSale(_upc);
    
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Sold'
  // Use the above modifiers to check if the item is received
  function buyItem(uint _upc) public payable
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc)  
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifier to check value
    checkValue(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].itemState = State.Purchased;
    items[_upc].ownerID = msg.sender;
    items[_upc].consumerID = msg.sender; 
    
    // Transfer money to distributor
    items[_upc].storeID.transfer(items[_upc].productPrice);    

    // Emit the appropriate event
    emit Purchased(_upc);
    
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originBrewerieID,
  string  originBrewerieName,
  string  originBrewerieInformation,
  string  originBrewerieLatitude,
  string  originBrewerieLongitude
  ) 
  {
    // Assign values to the 8 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    ownerID = items[_upc].ownerID;
    originBrewerieID = items[_upc].originBrewerieID;
    originBrewerieName = items[_upc].originBrewerieName;
    originBrewerieInformation = items[_upc].originBrewerieInformation;
    originBrewerieLatitude = items[_upc].originBrewerieLatitude;
    originBrewerieLongitude = items[_upc].originBrewerieLongitude;
   
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originBrewerieID,
  originBrewerieName,
  originBrewerieInformation,
  originBrewerieLatitude,
  originBrewerieLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address distributorID,
  address storeID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    productID = items[_upc].productID;
    productNotes = items[_upc].productNotes;
    productPrice = items[_upc].productPrice;
    itemState = uint(items[_upc].itemState);
    distributorID = items[_upc].distributorID;
    storeID = items[_upc].storeID;
    consumerID = items[_upc].consumerID;
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  distributorID,
  storeID,
  consumerID
  );
  }


  // 
  function fetchProductDetails(uint _upc) public view returns 
  (
   uint    sku,  // Stock Keeping Unit (SKU)
   uint    upc, // Universal Product Code (UPC), generated by the Brewerie, goes on the package, can be verified by the Consumer
   string  originBrewerieName, // Brewerie Name
   uint    productID,  // Product ID potentially a combination of upc + sku
   string  productNotes, // Product Notes
   string  productStyle, // Product Style
   uint    alcoholTax, // Alcohol Tax
   uint    productPrice // Product Price
   ) 
  {
  // Assign values
   sku = items[_upc].sku;
   upc = items[_upc].upc;
   originBrewerieName = items[_upc].originBrewerieName;
   productID = items[_upc].productID;  
   productNotes = items[_upc].productNotes;
   productStyle = items[_upc].productStyle;
   alcoholTax = items[_upc].alcoholTax;
   productPrice = items[_upc].productPrice;
  return 
  (
   sku,  
   upc, 
   originBrewerieName, 
   productID,  
   productNotes,
   productStyle, 
   alcoholTax, 
   productPrice 
  );
  }
}
