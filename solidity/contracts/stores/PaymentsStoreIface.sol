pragma solidity ^0.4.11;

contract PaymentsStoreIface {
    function payday(uint256 _employee_id, uint256 _pay_owed) public
    returns (bool _success);

    function addTokenAndDistToPay(uint256 _pay_id, address _token, uint256 _dist)
    returns (bool _success);

    function getPayment(uint256 _payment_id) public
    constant
    returns (address[] _tokens, uint256[] _dist, uint256 _total_usd, uint256 _ts);


    function getPayment(uint256 _employee_id, uint256 _ind) public
    constant
    returns (uint256 _payment_id, uint256 _total_usd, uint256 _ts);


    function getLastPayment(uint256 _employee_id) public
    constant
    returns (uint256 _payment_id, uint256 _total_usd, uint256 _ts);


    function getPaymentsCount() public constant
    returns (uint256 _payments_count);


    function getEmployeePaymentsCount(uint256 _employee_id) public constant
    returns (uint256 _employee_payments_count);
}
