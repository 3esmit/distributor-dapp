

const {
  BN, 
  time,        
  constants,    
  expectEvent,  
  expectRevert, 
} = require('@openzeppelin/test-helpers');
const ControlledSpec = require('./abstract/controlled');
const web3Utils = require('web3-utils');
const namehash = require('eth-ens-namehash');
const ethregistrarDuration = time.duration.years(9999)
let accountsArr;
config(
  {
    contracts: {        
      deploy: {    
        "ENSRegistry": {
        },
        "PublicResolver": {
          "args": [
            "$ENSRegistry"
          ]
        },
        "BaseRegistrarImplementation": {
          "args": [
            "$ENSRegistry", 
            "0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae" //eth.namehash
          ],
          "onDeploy": [
            "await ENSRegistry.methods.setSubnodeOwner('0x0000000000000000000000000000000000000000000000000000000000000000','0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0', BaseRegistrarImplementation.address).send()",
            "await BaseRegistrarImplementation.methods.addController(web3.eth.defaultAccount).send()",
            "await BaseRegistrarImplementation.methods.setResolver(PublicResolver.address).send()",
          ]
        },
        "DAptGet": {
          "args": [
            "0x35dcad9d6faf12cb07e3766b7626a4c991cf65242dc6c114e6ad230cd8bebff1",
            "$PublicResolver",
            "$accounts[0]",
            "$ENSRegistry"
          ],
          "onDeploy": [
            "await BaseRegistrarImplementation.methods.register('0xc1c685acc1281659f9d28f427afbdc0777de9c362f50ebabbd2a0febea59dead', web3.eth.defaultAccount,"+ethregistrarDuration+").send()",
            "await ENSRegistry.methods.setOwner('0x35dcad9d6faf12cb07e3766b7626a4c991cf65242dc6c114e6ad230cd8bebff1',DAptGet.address).send()"
          ]
        },
      }
    }
  }, (_err, web3_accounts) => {
    accountsArr = web3_accounts
  }
);

const ENSRegistry = artifacts.require('ENSRegistry');
const PublicResolver = artifacts.require('PublicResolver');
const DAptGet = artifacts.require('DAptGet');

contract('DAptGet', function () {
  ControlledSpec.Test(DAptGet);

  it("should set entry", async function() {
    await DAptGet.methods.addEntry("test", "0x11229988").send();
    let resolverAddress = await ENSRegistry.methods.resolver(namehash.hash("test.distributordapps.eth")).call();
    
    assert(resolverAddress, PublicResolver.address);
    let contenthash = await PublicResolver.methods.contenthash(namehash.hash("test.distributordapps.eth"));
    assert("0x11229988", contenthash);

  });
  
});
