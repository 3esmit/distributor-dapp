module.exports = {
  // default applies to all environments
  default: {
    library: 'embarkjs',  // can also be 'web3'

    // order of connections the dapp should connect to
    dappConnection: [
      "$EMBARK",
      "$WEB3",  // uses pre existing web3 object if available (e.g in Mist)
      "ws://localhost:8546",
      "http://localhost:8545"
    ],

    // Automatically call `ethereum.enable` if true.
    // If false, the following code must run before sending any transaction: `await EmbarkJS.enableEthereum();`
    // Default value is true.
    dappAutoEnable: false,
    
    gas: "auto",

    // Strategy for the deployment of the contracts:
    // - implicit will try to deploy all the contracts located inside the contracts directory
    //            or the directory configured for the location of the contracts. This is default one
    //            when not specified
    // - explicit will only attempt to deploy the contracts that are explicitly specified inside the
    //            contracts section.
    strategy: 'explicit',

    // minimalContractSize, when set to true, tells Embark to generate contract files without the heavy bytecodes
    // Using filteredFields lets you customize which field you want to filter out of the contract file (requires minimalContractSize: true)
    // minimalContractSize: false,
    // filteredFields: [],

    deploy: {
      ENSRegistry: {
        deploy: true,
        onDeploy: [
          "ENSRegistry.methods.setSubnodeOwner('0x0000000000000000000000000000000000000000000000000000000000000000', '0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0', web3.eth.defaultAccount).send()",
        ]
      },
      PublicResolver: {
        deploy: true,
        args: [
          "$ENSRegistry"
        ]
      },
      DAptGet: {
        args: [
          "0x35dcad9d6faf12cb07e3766b7626a4c991cf65242dc6c114e6ad230cd8bebff1",
          "$PublicResolver",
          "$accounts[0]",
          "$ENSRegistry"
        ],
        onDeploy: [
          "ENSRegistry.methods.setSubnodeOwner('0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae', '0xc1c685acc1281659f9d28f427afbdc0777de9c362f50ebabbd2a0febea59dead','$DAptGet').send()"
        ]
        
      },
    }
  },

  goerli: {
    dappConnection: [
      "$WEB3",
      "ws://localhost:8546",
      "http://localhost:8545"
    ],
    deploy: {
      ENSRegistry: {
        address: "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
      },
      PublicResolver: {
        address: "0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41"
      },
      DAptGet: {
        args: [
          "0x879B17290648fa0d24a6d5297B82Bf6AB0aB54B9",
          "$ENSRegistry",
          "$PublicResolver",
          "0xd68b70bccaa1e1197bb35ff86078adada48ec7d9d5e6a09305d4eb51179d8f7c"
        ]
      },
    }
  },

  // default environment, merges with the settings in default
  // assumed to be the intended environment by `embark run`
  development: {},

  // merges with the settings in default
  // used with "embark run privatenet"
  privatenet: {},

  // you can name an environment with specific settings and then specify with
  // "embark run custom_name" or "embark blockchain custom_name"
  // custom_name: {}
};
