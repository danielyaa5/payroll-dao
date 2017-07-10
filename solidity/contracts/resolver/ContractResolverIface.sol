pragma solidity ^0.4.11;

contract ContractResolverIface {
    function registerContract(bytes32 _contract_name, address _contract_address) public
    returns (bool _success);


    function upgradeContract(bytes32 _contract_name, address _new_contract_address) public
    returns (bool _success);


    function getContractAddress(bytes32 _contract_name) public
    constant
    returns (address _contract_address);


    function getContractName(address _contract_address) public
    constant
    returns (bytes32 _contract_name);


    function addAdmin(address _new_admin) public
    returns (bool _success);


    function removeAdmin(address _removal_admin) public
    returns (bool _success);


    function addGroupie(bytes32 _group_name, address _new_groupie) public
    returns (bool _success);


    function removeGroupie(bytes32 _group_name, address _removal_groupie) public
    returns (bool _success);


    function isGroupie(bytes32 _group_name, address _groupie) public
    constant
    returns (bool _is_groupie);


    function isOwnerAddress(address _owner) public
    constant
    returns (bool _is_owner);


    function isAdmin(address _account) public
    constant
    returns (bool _is_admin);


    function pause()
    returns (bool _success);


    function resume()
    returns (bool _success);


    function isPaused() public
    constant
    returns (bool _is_paused);


    function rateLimit(address _user, uint256 _num_calls, uint256 _time_period, bytes32 _rl_group) public
    returns (bool _is_rate_limited);


    function addAllowedToken(address _token_address) public
    returns (bool _success);


    function removeAllowedToken(address _token_address) public
    returns (bool _success);


    function isAllowedToken(address _token_address) public
    constant
    returns (bool _is_allowed);


    function isAllowedTokens(address[] _token_addresses) public
    constant
    returns (bool _is_allowed_addresses);


    function getAllowedToken(uint256 i) public
    constant
    returns (address _allowed_token);


    function getAllowedTokensCount() public
    constant
    returns (uint256 _allowed_token_count);
}
