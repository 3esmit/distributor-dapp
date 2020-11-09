// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.6.0;

import "./ENSSubdomainRegistrar.sol";
import "./DAptGetEntry.sol";
import "../common/Controlled.sol";
import "../ens/ENS.sol";
import "../ens/PublicResolver.sol";

/**
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 * @title DAptGet
 * @notice Distributes Dapps
 * @dev Unsafe contract! Do not use in production!
 */
contract DAptGet is ENSSubdomainRegistrar, Controlled {
    event Created(bytes32 indexed label, address _entry);
    string[] public list;

    constructor(
        address payable _controller,
        ENS _ensRegistry,
        PublicResolver _resolver,
        bytes32 _ensNode
    )
        public
        Controlled(_controller)
        ENSSubdomainRegistrar(
            _ensRegistry,
            _resolver,
            _ensNode
        )
    {

    }

    function createApp(string calldata _name) external virtual {
        bytes32 label = keccak256(abi.encodePacked(_name));
        bytes32 subnode = keccak256(abi.encodePacked(ensNode, label));
        address entry = address(new DAptGetEntry(msg.sender, ensRegistry, defaultResolver, subnode));
        _register(entry, label);
        list.push(_name);
        emit Created(label, entry);
    }

}
