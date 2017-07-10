pragma solidity ^0.4.11;

import '../libs/StrLib.sol';
import '../tokens/Token.sol';
import './FundsStoreIface.sol';
import '../libs/ConvertLib.sol';
import '../handlers/FundsHandler.sol';
import '../resolver/ResolverClient.sol';
import '../installed/zeppelin/SafeMath.sol';
import '../installed/zeppelin/ReentrancyGuard.sol';

contract FundsStore is FundsStoreIface, ResolverClient, ReentrancyGuard, FundsHandler {
    using SafeMath for uint;

    bytes32 private C_FUNDS;
    bytes32 private USD;
    address private ETH_ADR;
    address[] private ALLOWED_TOKENS;

    mapping(address => uint256) ExRateMap; // conversion of decimal unit of token to usd


    function FundsStore(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        USD = getConst().USD();
        ETH_ADR = getConst().ETH_ADR();

        for (uint256 i = 0; i < contractResolver.getAllowedTokensCount(); i++)
        {
            ALLOWED_TOKENS.push(contractResolver.getAllowedToken(i));
        }
    }


    function addTokenFunds(address, uint256 _value, address _token) public
    ifSenderIs(C_FUNDS)
    returns (bool _success)
    {
        FundMap[_token] = FundMap[_token] + _value;
        _success = true;
    }


    function addEthFunds() public payable
    ifSenderIs(C_FUNDS)
    returns (bool _success)
    {
        FundMap[ETH_ADR] = FundMap[ETH_ADR] + msg.value;
        require(FundMap[ETH_ADR] == this.balance);
        _success = true;
    }


    function scapeHatch() public
    ifSenderIs(C_FUNDS)
    returns (bool _success)
    {
        for (uint256 i = 0; i < ALLOWED_TOKENS.length; i++) {
            Token(ALLOWED_TOKENS[i]).transferFrom(this, getOwner(), FundMap[ALLOWED_TOKENS[i]]);
        }
        _success = getOwner().send(this.balance);
    }


    function setExchangeRate(address _token, uint256 _atoms_per_usd) public
    ifSenderIs(C_FUNDS)
    returns (bool _success)
    {
        ExRateMap[_token] = _atoms_per_usd;
        _success = true;
    }


    function getExchangeRate(address _token) public constant
    ifSenderIs(C_FUNDS)
    returns (uint256 _atoms_per_usd)
    {
        _atoms_per_usd = ExRateMap[_token];
    }


    function getTotalFunds() public
    constant
    ifSenderIs(C_FUNDS)
    returns (uint256 _total_funds_usd)
    {
        _total_funds_usd = 0;
        for (uint256 i = 0; i < ALLOWED_TOKENS.length; i++)
        {
            _total_funds_usd += ConvertLib.convert(FundMap[ALLOWED_TOKENS[i]], getExchangeRate(ALLOWED_TOKENS[i]));
        }
        _total_funds_usd += ConvertLib.convert(FundMap[ETH_ADR], getExchangeRate(ETH_ADR));
    }


    function sendFund(address _token, address _to, uint256 _amt) public
    ifSenderIs(C_FUNDS)
    returns (bool _success)
    {
        if (FundMap[_token] < _amt) return false;
        if(_token == ETH_ADR)
        {
            asyncSend(_to, _amt);
        }
        else
        {
            Token(_token).transferFrom(_token, _to, _amt);
        }

        FundMap[_token] = FundMap[_token].sub(_amt);
        _success = true;
    }
}
