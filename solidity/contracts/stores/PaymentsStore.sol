pragma solidity ^0.4.11;

import './PaymentsStoreIface.sol';
import '../ownership/HasNoFunds.sol';
import '../resolver/ResolverClient.sol';

contract PaymentsStore is PaymentsStoreIface, ResolverClient, HasNoFunds {
    bytes32 private C_PAYMENTS;
    struct Payment {
        address[] tokens;
        uint256[] distributions;
        uint256 total_usd;
        uint256 ts;
    }
    uint256[][] private employee_to_payments; // map employee id to array payment ids
    Payment[] private payments; // most recent payments at end of array

    function PaymentsStore(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        C_PAYMENTS = getConst().C_PAYMENTS();
    }

    function payday(uint256 _employee_id, uint256 _pay_owed) public
    ifSenderIs(C_PAYMENTS)
    returns (bool _success)
    {
        employee_to_payments[_employee_id].push(payments.length);
        payments[payments.length].total_usd = _pay_owed;
        payments[payments.length].ts = now;
        _success = true;
    }

    function addTokenAndDistToPay(uint256 _pay_id, address _token, uint256 _dist)
    ifSenderIs(C_PAYMENTS)
    returns (bool _success)
    {
        payments[_pay_id].tokens.push(_token);
        payments[_pay_id].distributions.push(_dist);
        _success = true;
    }

    function getPayment(uint256 _payment_id) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (address[] _tokens, uint256[] _dist, uint256 _total_usd, uint256 _ts)
    {
        _tokens = payments[_payment_id].tokens;
        _dist = payments[_payment_id].distributions;
        _total_usd = payments[_payment_id].total_usd;
        _ts = payments[_payment_id].ts;
    }


    function getPayment(uint256 _employee_id, uint256 _ind) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _payment_id, uint256 _total_usd, uint256 _ts)
    {
            _payment_id = employee_to_payments[_employee_id][_ind];
            _total_usd = payments[_payment_id].total_usd;
            _ts = payments[_payment_id].ts;
    }


    function getLastPayment(uint256 _employee_id) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _payment_id, uint256 _total_usd, uint256 _ts)
    {
        uint256 employee_payments_count = getEmployeePaymentsCount(_employee_id);
        if (employee_payments_count > 0)
        {
            (_payment_id, _total_usd, _ts) = getPayment(_employee_id, employee_payments_count);
        }
    }


    function getPaymentsCount() public constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _payments_count)
    {
        return payments.length;
    }


    function getEmployeePaymentsCount(uint256 _employee_id) public constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _employee_payments_count)
    {
        _employee_payments_count = employee_to_payments[_employee_id].length;
    }
}
