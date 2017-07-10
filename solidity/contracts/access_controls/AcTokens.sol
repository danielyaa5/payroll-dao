pragma solidity ^0.4.11;

import './AcGroups.sol';

// Access Control Contract
contract AcTokens is AcGroups {
    bytes32 private ADMINS;
    bytes32 private ALLOWED_TOKENS;

    uint256 private num_allowed_tokens;
    // WARN: Do not trust this array, it will still contain removed tokens, check that they are truly allowed
    address[] private allowed_token_addresses;

    function AcTokens() {
        ADMINS = const.ADMINS();
        ALLOWED_TOKENS = const.ALLOWED_TOKENS();
    }


    function addAllowedToken(address _token_address) public
    onlyOwner
    returns (bool _success)
    {
        if(_token_address == address(0)) return false;
        if(isAllowedToken(_token_address)) return true;
        addGroupie(ALLOWED_TOKENS, _token_address);
        allowed_token_addresses.push(_token_address);
        num_allowed_tokens = num_allowed_tokens + 1;
        _success = true;
    }


    function removeAllowedToken(address _token_address) public
    onlyOwner
    returns (bool _success)
    {
        GroupsMap[ALLOWED_TOKENS][_token_address] = false;
        num_allowed_tokens = num_allowed_tokens - 1;
        cleanAllowedTokens(_token_address);
        _success = true;
    }


    function isAllowedToken(address _token_address) public
    constant
    returns (bool _is_allowed)
    {
        _is_allowed = isGroupie(ALLOWED_TOKENS, _token_address);
    }


    function isAllowedTokens(address[] _token_addresses) public
    constant
    returns (bool _is_allowed_addresses)
    {
        for (uint256 i = 0; i < _token_addresses.length; i++)
        {
            if (isAllowedToken(_token_addresses[i]) == false) return false;
        }
        _is_allowed_addresses = true;
    }


    function getAllowedToken(uint256 i) public
    constant
    returns (address _allowed_token)
    {
        _allowed_token = allowed_token_addresses[i];
    }


    function getAllowedTokensCount() public
    constant
    returns (uint256 _allowed_token_count)
    {
        _allowed_token_count = num_allowed_tokens;
    }


    function cleanAllowedTokens(address _removed_token) private
    constant
    {
        uint256 ind = 0;
        for (uint256 i = 0; i < allowed_token_addresses.length; i++)
        {
            if (allowed_token_addresses[i] == _removed_token)
            {
                allowed_token_addresses[i] = address(0);
                ind = i;
            }
            else
            {
                if (ind != i) allowed_token_addresses[ind++] = allowed_token_addresses[i];
                allowed_token_addresses[i] = address(0);
            }
        }
    }

}
