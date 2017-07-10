pragma solidity ^0.4.11;

import './Token.sol';

/**
 * @title AwesomeToken
 * @dev Very simple ERC20 Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract AwesomeToken is Token {

    bytes32 private constant NAME = 'AwesomeToken';
    bytes32 private constant SYMBOL = 'AWE';
    uint256 private constant PRICE = 5 ether;
    uint256 private constant DECIMALS = 18;
    uint256 private constant INITIAL_SUPPLY = 10**18;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function AragonToken() {
        setToken(NAME, SYMBOL, DECIMALS);
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    /**
     * @dev replace this with any other price function
     * @return The wei price per unit of token.
     */
    function getPrice() public constant returns (uint256 result) { return PRICE; }
}

