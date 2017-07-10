pragma solidity ^0.4.11;

import './Token.sol';

/**
 * @title UsdToken
 * @dev Very simple ERC20 Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract UsdToken is Token {

    bytes32 private constant NAME = 'UsdToken';
    bytes32 private constant SYMBOL = 'USD';
    uint256 private constant DECIMALS = 18;
    uint256 private constant INITIAL_SUPPLY = 10**18;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function UsdToken()
    {
        setToken(NAME, SYMBOL, DECIMALS);
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}

