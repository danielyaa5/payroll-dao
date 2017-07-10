pragma solidity ^0.4.11;

import '../installed/zeppelin/token/PausableToken.sol';

contract TokenRecipient { function addTokenFunds(address _from, uint256 _value, address _token, bytes32 _extra_data); }

contract Token is PausableToken {
    bytes32 private name;
    bytes32 private symbol;
    uint256 private decimals;

    function setToken(bytes32 _name, bytes32 _symbol, uint256 _decimals)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function approveAndCall(address _spender, uint256 _value) public
    returns (bool _success)
    {
        TokenRecipient spender = TokenRecipient(_spender);
        approve(_spender, _value);
        spender.addTokenFunds(msg.sender, _value, this, symbol);
        _success = true;
    }

    function getName() public constant returns (bytes32 _name) { _name = name; }
    function getSymbol() public constant returns (bytes32 _symbol) { _symbol = symbol; }
    function getDecimals() public constant returns (uint256 _decimals) { _decimals = decimals; }
}
