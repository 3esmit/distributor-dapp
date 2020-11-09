// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.6.0;

import "./ENSSubdomainRegistrar.sol";
import "../common/Controlled.sol";
import "../ens/ENS.sol";
import "../ens/PublicResolver.sol";

/**
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 * @title DAptGet
 * @notice Distributes Dapps
 */
contract DAptGetEntry is ENSSubdomainRegistrar, Controlled {
    event Release(bytes32 indexed label, bytes contenthash);
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

    function addDistro(
        string calldata _distro,
        bytes calldata _contenthash
    )
        external
        virtual
        onlyController
    {
        bytes32 label = keccak256(abi.encodePacked(_distro));
        _register(address(this), label, _contenthash);
        list.push(_distro);
        emit Release(label, _contenthash);
    }

}
