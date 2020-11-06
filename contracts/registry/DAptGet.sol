// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.6.0;

import "../common/Controlled.sol";
import "../ens/ENS.sol";
import "../ens/PublicResolver.sol";

/**
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 * @title DAptGet
 * @notice Distributes Dapps
 * @dev Unsafe contract! Do not use in production!
 */
contract DAptGet is Controlled {
    event Release(bytes32 indexed label, bytes contenthash);
    ENS public ensRegistry;
    string[] public list;
    bytes32 public ensNode;
    PublicResolver public defaultResolver;
    
    constructor(bytes32 _ensNode, PublicResolver _resolver, address payable _controller, ENS _ensRegistry) public Controlled(_controller) {
        ensRegistry = _ensRegistry;
        ensNode = _ensNode;
        defaultResolver = _resolver;
    }

    function addEntry(string calldata _name, bytes calldata _contenthash) external {
        bytes32 label = keccak256(abi.encodePacked(_name));
        bytes32 subnode = ensRegistry.setSubnodeOwner(ensNode, label, address(this));
        ensRegistry.setResolver(subnode, address(defaultResolver));
        defaultResolver.setContenthash(subnode, _contenthash);
        ensRegistry.setOwner(subnode, msg.sender);
        list.push(_name);
        emit Release(label, _contenthash);
    }
}
