

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
            "$accounts[0]",
            "$ENSRegistry",
            "$PublicResolver",
            "0x35dcad9d6faf12cb07e3766b7626a4c991cf65242dc6c114e6ad230cd8bebff1"
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
const DAptGetEntry = artifacts.require('DAptGetEntry');

contract('DAptGet', function () {
  ControlledSpec.Test(DAptGet);

  it("should create app", async function() {
    await DAptGet.methods.createApp("statusdesktop").send({from: accountsArr[0]});
    let ownerAddress = await ENSRegistry.methods.owner(namehash.hash("statusdesktop.distributordapps.eth")).call();
    
    assert(ownerAddress != constants.ZERO_ADDRESS);

  });
  xWit("should create a distro", async function() {
    let ownerAddress = await ENSRegistry.methods.owner(namehash.hash("statusdesktop.distributordapps.eth")).call();
    let appEntry = new web3.eth.Contract(DAptGetEntry.abiDefinition, ownerAddress);
    await appEntry.methods.addDistro("linux64", "0x11229988").send({gas: 1000000, from: accountsArr[0]});
    let contenthash = await PublicResolver.methods.contenthash(namehash.hash("linux64.statusdesktop.distributordapps.eth"));
    assert("0x11229988", contenthash);
  });
  it("controller should remove distros", async function() {
    await DAptGet.methods.removeApp("statusdesktop", ["linux64"]).send({from: accountsArr[0]});
    
    let ownerAddress = await ENSRegistry.methods.owner(namehash.hash("statusdesktop.distributordapps.eth")).call();
    let resolverAddress = await ENSRegistry.methods.resolver(namehash.hash("statusdesktop.distributordapps.eth")).call();
    assert(constants.ZERO_ADDRESS, ownerAddress);
    assert(constants.ZERO_ADDRESS, resolverAddress);

    ownerAddress = await ENSRegistry.methods.owner(namehash.hash("linux64.statusdesktop.distributordapps.eth")).call();
    resolverAddress = await ENSRegistry.methods.resolver(namehash.hash("linux64.statusdesktop.distributordapps.eth")).call();
    assert(constants.ZERO_ADDRESS, resolverAddress);
    assert(constants.ZERO_ADDRESS, ownerAddress);
  });
});
