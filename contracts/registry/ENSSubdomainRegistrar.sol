// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.6.0;

import "../common/Controlled.sol";
import "../ens/ENS.sol";
import "../ens/PublicResolver.sol";

/**
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 * @title ENSSubdomainRegistrar
 * @notice Simple Abstract Registrar for registering ENS subdomains
 */
abstract contract ENSSubdomainRegistrar {
    ENS public ensRegistry;
    bytes32 public ensNode;
    PublicResolver public defaultResolver;
    
    constructor(
        ENS _ensRegistry,
        PublicResolver _resolver,
        bytes32 _ensNode
    ) internal {
        ensRegistry = _ensRegistry;
        ensNode = _ensNode;
        defaultResolver = _resolver;
    }

    function _register(
        address _owner,
        bytes32 _label
    )
        internal 
        virtual 
        returns (bytes32 subnode)
    {
        subnode = ensRegistry.setSubnodeOwner(ensNode, _label, _owner);
    }

    function _register(
        address _owner,
        bytes32 _label,
        bytes memory _contenthash
    )
        internal 
        virtual 
        returns (bytes32 subnode)
    {
        subnode = _register(address(this), _label);
        ensRegistry.setResolver(subnode, address(defaultResolver));
        defaultResolver.setContenthash(subnode, _contenthash);
        ensRegistry.setOwner(subnode, _owner);
    }
    
}
