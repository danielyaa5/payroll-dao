pragma solidity ^0.4.11;

contract FundsStoreIface {
    function addTokenFunds(address, uint256 _value, address _token) public
    returns (bool _success);


    function addEthFunds() public payable
    returns (bool _success);


    function scapeHatch() public
    returns (bool _success);


    function setExchangeRate(address _token, uint256 _atoms_per_usd) public
    returns (bool _success);


    function getExchangeRate(address _token) public constant
    returns (uint256 _atoms_per_usd);


    function getTotalFunds() public
    constant
    returns (uint256 _total_funds_usd);


    function sendFund(address _token, address _to, uint256 _amt) public
    returns (bool _success);


    function withdrawEthPayments(address _payee) public;
}
