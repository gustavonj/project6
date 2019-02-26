App = {
    web3Provider: null,
    contracts: {},
    emptyAddress: "0x0000000000000000000000000000000000000000",
    sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000", //TODO:
    originBrewerieID: "0x0000000000000000000000000000000000000000", //TODO:
    originBrewerieName: null,
    originBrewerieInformation: null,
    originBrewerieLatitude: null,
    originBrewerieLongitude: null,
    productNotes: null,
    productPrice: 0,
    distributorID: "0x0000000000000000000000000000000000000000", //TODO:
    retailerID: "0x0000000000000000000000000000000000000000",//TODO:
    consumerID: "0x0000000000000000000000000000000000000000",//TODO:

    init: async function () {
        App.readForm();
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    readForm: function () {
        App.sku = $("#sku").val();
        App.upc = $("#upc").val();
        App.ownerID = $("#ownerID").val();
        App.originBrewerieID = $("#originBrewerieID").val();
        App.originBrewerieName = $("#originBrewerieName").val();
        App.originBrewerieInformation = $("#originBrewerieInformation").val();
        App.originBrewerieLatitude = $("#originBrewerieLatitude").val();
        App.originBrewerieLongitude = $("#originBrewerieLongitude").val();
        App.productNotes = $("#productNotes").val();
        App.productStyle = $("#productStyle").val();
        App.alcoholTax = $("#alcoholTax").val();
        App.productPrice = $("#productPrice").val();
        App.distributorID = $("#distributorID").val();
        App.storeID = $("#storeID").val();
        App.consumerID = $("#consumerID").val();

        console.log(
            App.sku,
            App.upc,
            App.ownerID, 
            App.originBrewerieID, 
            App.originBrewerieName, 
            App.originBrewerieInformation, 
            App.originBrewerieLatitude, 
            App.originBrewerieLongitude, 
            App.productNotes, 
            App.productStyle,
            App.alcoholTax,
            App.productPrice, 
            App.distributorID, 
            App.retailerID, 
            App.consumerID
        );
    },

    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }

        App.getMetaskAccountID();

        return App.initSupplyChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            console.log('getMetaskID:',res);
            App.metamaskAccountID = res[0];

        })
    },

    initSupplyChain: function () {
        /// Source the truffle compiled smart contracts
        var jsonSupplyChain='../../build/contracts/SupplyChain.json';
        
        /// JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, function(data) {
            console.log('data',data);
            var SupplyChainArtifact = data;
            App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
            App.contracts.SupplyChain.setProvider(App.web3Provider);
            
            App.fetchItemBufferOne();
            App.fetchItemBufferTwo();
            App.fetchEvents();//TODO:

        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        App.getMetaskAccountID();

        var processId = parseInt($(event.target).data('id'));
        console.log('processId',processId);

        switch(processId) {
            case 1:
                return await App.brewsItem(event);
                break;
            case 2:
                return await App.bottleUp(event);
                break;
            case 3:
                return await App.packagingItem(event);
                break;
            case 4:
                return await App.buyPackageItem(event);
                break;
            case 5:
                return await App.enableForOrder(event);
                break;
            case 6:
                return await App.orderItem(event);
                break;
            case 7:
                return await App.shipItem(event);
                break;
            case 8:
                return await App.receiveItem(event);
                break;
            case 9:
                return await App.putsItemOnSale(event);
                break;
            case 10:
                return await App.buyItem(event);
                break;
            case 11:
                return await App.fetchItemBufferOne(event);
                break;
            case 12:
                return await App.fetchItemBufferTwo(event);
                break;
            }
    },

    brewsItem: function(event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.brewsItem(
                App.upc, 
                App.metamaskAccountID, 
                App.originBrewerieName, 
                App.originBrewerieInformation, 
                App.originBrewerieLatitude, 
                App.originBrewerieLongitude, 
                App.productNotes,
                App.productStyle,
                App.alcoholTax
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('brewsItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    bottleUp: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.bottleUp(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('bottleUp',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    packagingItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.packagingItem(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('packagingItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyPackageItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(App.productPrice, "ether");
            return instance.buyPackageItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyPackageItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    enableForOrder: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.enableForOrder(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('enableForOrder',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    orderItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));
        
        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(App.productPrice, "ether");
            return instance.orderItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('orderItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },


    shipItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.shipItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('shipItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    receiveItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.receiveItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('receiveItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    putsItemOnSale: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.putsItemOnSale(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('putsItemOnSale',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(App.productPrice, "ether");
            return instance.buyItem(App.upc, {from: App.metamaskAccountID,  value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    

    fetchItemBufferOne: function () {
    ///   event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
        App.upc = $('#upc').val();
        console.log('upc',App.upc);

        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferOne(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchItemBufferOne', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchItemBufferTwo: function () {
    ///    event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
                        
        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferTwo.call(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchItemBufferTwo', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchEvents: function () {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = function () {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                App.contracts.SupplyChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.SupplyChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });
        
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
