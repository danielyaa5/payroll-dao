pragma solidity ^0.4.11;

import './ContractResolverIface.sol';
import './ResolverManagerIface.sol';

contract ResolverManager is ResolverManagerIface {
    ContractResolverIface private currentVersion;

    modifier onlyOwner()
    {
        assert(currentVersion.isOwnerAddress(msg.sender));
        _;
    }


    function ResolverManager(address _init_addr)
    {
        currentVersion = ContractResolverIface(_init_addr);
        assert(currentVersion.isOwnerAddress(msg.sender));
    }


    function update(address _new_address) public
    onlyOwner
    returns (bool _success)
    {
        currentVersion = ContractResolverIface(_new_address);
        _success = true;
    }


    function getResolver() public
    constant
    returns (address _resolver)
    {
        _resolver = currentVersion;
    }
}