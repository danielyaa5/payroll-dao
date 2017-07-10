pragma solidity ^0.4.11;

import '../libs/StrLib.sol';
import './FundsCtrlIface.sol';
import '../libs/ConvertLib.sol';
import '../stores/FundsStoreIface.sol';
import '../ownership/HasNoFunds.sol';
import '../resolver/ResolverClient.sol';

contract FundsCtrl is FundsCtrlIface, ResolverClient, HasNoFunds {
    bytes32 private S_FUNDS;
    bytes32 private C_FUNDS;
    bytes32 private C_PAYMENTS;
    bytes32 private A_PAYROLL;
    address private ETH_ADR;
    address[] private ALLOWED_TOKENS;

    function FundsCtrl(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        S_FUNDS = getConst().S_FUNDS();
        C_FUNDS = getConst().C_FUNDS();
        C_PAYMENTS = getConst().C_PAYMENTS();
        A_PAYROLL = getConst().A_PAYROLL();
        ETH_ADR = getConst().ETH_ADR();

        for (uint256 i = 0; i < contractResolver.getAllowedTokensCount(); i++)
        {
            ALLOWED_TOKENS.push(contractResolver.getAllowedToken(i));
        }
    }


    function addEthFunds() public
    payable
    ifSenderIs(A_PAYROLL)
    {
        assert(FundsStoreIface(getContract(S_FUNDS)).addEthFunds.value(msg.value)());
    }


    function scapeHatch() public
    ifSenderIs(A_PAYROLL)
    {
        assert(FundsStoreIface(getContract(S_FUNDS)).scapeHatch());
        assert(contractResolver.pause());
    }


    function setExchangeRate(address _token, uint256 _atoms_per_usd) public
    ifSenderIs(A_PAYROLL)
    {
        require(_atoms_per_usd > 0);
        assert(FundsStoreIface(getContract(S_FUNDS)).setExchangeRate(_token, _atoms_per_usd));
    }


    function getExchangeRate(address _token) public
    constant
    onlyResolverContract
    returns (uint256 _usd_ex_rate)
    {
        _usd_ex_rate = FundsStoreIface(getContract(S_FUNDS)).getExchangeRate(_token);
    }


    function getTotalFunds() public
    constant
    onlyResolverContract
    returns (uint256 _total_funds_usd)
    {
        _total_funds_usd = FundsStoreIface(getContract(S_FUNDS)).getTotalFunds();
    }


    function addTokenFunds(address _from, uint256 _value, address _token) public
    ifSenderIs(A_PAYROLL)
    returns (bool _success)
    {
        _success = FundsStoreIface(getContract(S_FUNDS)).addTokenFunds(_from, _value, _token);
    }


    function sendFunds(address _to, address[] _tokens, uint256[] payments)
    ifSenderIs(C_PAYMENTS)
    {
        // check if there are enough funds to pay the employee
        for (uint256 i = 0; i < payments.length; i++)
        {
            if (i == 0)
            {
                assert(FundsStoreIface(getContract(S_FUNDS)).sendFund(ETH_ADR, _to, payments[i]));
            }
            else
            {
                assert(FundsStoreIface(getContract(S_FUNDS)).sendFund(_tokens[i-1], _to, payments[i]));
            }
        }
    }


    function sendFund(address _token, address _to, uint256 _amt) public
    constant
    ifSenderIs(C_PAYMENTS)
    {
        assert(FundsStoreIface(getContract(S_FUNDS)).sendFund(_token, _to, _amt));
    }


    function withdrawEthFunds(address _for) public
    onlyGroupie(A_PAYROLL)
    {
        FundsStoreIface(getContract(S_FUNDS)).withdrawEthPayments(_for);
    }
}
