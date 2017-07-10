pragma solidity ^0.4.11;

import '../resolver/ResolverClient.sol';
import '../installed/zeppelin/SafeMath.sol';


/**
 * @title FundsHandler
 * @dev Base contract supporting async send for pull payments. Inherit from this
 * contract and use asyncSend instead of send.
 */
contract FundsHandler is ResolverClient {
    using SafeMath for uint;

    bytes32 internal C_FUNDS;
    bytes32 internal A_PAYROLL;
    address internal ETH_ADR;

    mapping(address => uint256) private payments;
    uint256 private totalPayments;

    mapping(address => uint256) internal FundMap; // Map token address to token balance

    function PullPayment() {
        C_FUNDS = getConst().C_FUNDS();
        A_PAYROLL = getConst().A_PAYROLL();
        ETH_ADR = getConst().ETH_ADR();
    }
    /**
    * @dev Called by the payer to store the sent amount as credit to be pulled.
    * @param dest The destination address of the funds.
    * @param amt The amount to transfer.
    */
    function asyncSend(address dest, uint256 amt) internal
    {
        payments[dest] = payments[dest].add(amt);
        totalPayments = totalPayments.add(amt);
    }

    /**
    * @dev withdraw accumulated balance, called by payee.
    */
    function withdrawEthPayments(address _payee) public
    ifSenderIs(C_FUNDS)
    {
        uint256 payment = payments[_payee];
        uint256 total_eth_funds = getFundTotal(ETH_ADR);
        assert(payment != 0);
        assert(total_eth_funds >= payment);
        setFundTotal(ETH_ADR, total_eth_funds.sub(payment));
        payments[_payee] = 0;
        assert(_payee.send(payment));
    }


    function getFundTotal(address _token) internal
    constant
    returns (uint256 _fund_total)
    {
        _fund_total = FundMap[_token];
    }


    function setFundTotal(address _token, uint256 _amt) internal
    constant
    returns (bool _success)
    {
        FundMap[_token] = _amt;
        _success = true;
    }
}
