pragma solidity ^0.4.11;

contract ResolverManagerIface {
    function update(address _new_address) public
    returns (bool _success);


    function getResolver() public
    constant
    returns (address _resolver);
}