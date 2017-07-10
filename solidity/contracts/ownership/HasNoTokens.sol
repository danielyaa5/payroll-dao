pragma solidity ^0.4.11;

import '../installed/zeppelin/token/ERC20.sol';
import '../installed/zeppelin/ownership/Ownable.sol';

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is Ownable {

    /**
     * @dev Reject all ERC23 compatible tokens
     * param1 address The address that is transferring the tokens
     * param2 _value Uint the amount of the specified token
     * param3 _data Bytes The data passed from the caller.
     */
    function tokenFallback(address, uint, bytes) external { throw; }

    /**
     * @dev Reclaim all ERC20Basic compatible tokens
     * @param _token_address address The address of the token contract
     */
    function reclaimToken(address _token_address) external
    onlyOwner
    {
        ERC20Basic tokenInst = ERC20Basic(_token_address);
        uint256 balance = tokenInst.balanceOf(this);
        tokenInst.transfer(owner, balance);
    }
}
