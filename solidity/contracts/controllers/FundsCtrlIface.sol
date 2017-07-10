pragma solidity ^0.4.11;

contract FundsCtrlIface {
    function addEthFunds() public
    payable;


    function scapeHatch() public;


    function setExchangeRate(address _token, uint256 _atoms_per_usd) public;


    function getExchangeRate(address _token) public
    constant
    returns (uint256 _usd_ex_rate);


    function getTotalFunds() public
    constant
    returns (uint256 _total_funds_usd);


    function addTokenFunds(address _from, uint256 _value, address _token) public
    returns (bool _success);


    function sendFunds(address _to, address[] _tokens, uint256[] payments);


    function sendFund(address _token, address _to, uint256 _amt) public
    constant;


    function withdrawEthFunds(address _for) public;
}
