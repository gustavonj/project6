/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

var HDWalletProvider = require("truffle-hdwallet-provider")
var mnemonic = "air fence artefact damage advice giggle change time rookie this motor catch"

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
      networks: { 
        development: {
          host: '127.0.0.1',
          port: 8545,
          network_id: "*"
        }, 
        rinkeby: {
          provider: function() {
            return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/0a28c2c71f57409f8a9600ef7772f4bf")
          },
          network_id: 4,
          gas : 4500000,
          gasPrice : 10000000000
        },
      }
    };
