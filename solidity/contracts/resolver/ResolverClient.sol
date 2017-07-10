pragma solidity ^0.4.11;

import './ResolverManagerIface.sol';
import './ContractResolverIface.sol';
import '../stores/ConstantsStore.sol';

// WARN: updateResolver modifier must be first
contract ResolverClient {
    bytes32 private ALLOWED_TOKENS;
    bytes32 private OR_RESOLVER;
    bytes32 private S_CONSTANTS = 's:constants';

    ResolverManagerIface internal resolverManager;
    ContractResolverIface internal contractResolver;

    address private owner;

    modifier updateResolver()
    {
        contractResolver = ContractResolverIface(resolverManager.getResolver());
        assert(contractResolver != address(0));
        _;
    }


    modifier ifSenderIs(bytes32 _contract_name)
    {
        assert(getContract(_contract_name) == msg.sender);
        _;
    }


    modifier onlyResolverContract()
    {
        assert(isContractInResolver());
        _;
    }


    modifier onlyAdmin()
    {
        assert(contractResolver.isAdmin(msg.sender));
        _;
    }


    modifier onlyGroupie(bytes32 _group_name)
    {
        assert(contractResolver.isGroupie(_group_name, msg.sender));
        _;
    }


    modifier onlyOwner()
    {
        assert(getOwner() == msg.sender);
        _;
    }


    modifier onlyAllowedTokens()
    {
        assert(contractResolver.isGroupie(ALLOWED_TOKENS, msg.sender));
        _;
    }


    modifier whenActive()
    {
        assert(!contractResolver.isPaused());
        _;
    }


    modifier whenPaused
    {
        assert(contractResolver.isPaused());
        _;
    }


    modifier rateLimit(uint256 _num_calls, uint256 _time_period, bytes32 _rl_group)
    {
        bool should_rate_limit = contractResolver.rateLimit(msg.sender, _num_calls, _time_period, _rl_group);
        assert(should_rate_limit == false);
        _;
    }


    function ResolverClient(address _resolver_manager) internal
    {
        resolverManager = ResolverManagerIface(_resolver_manager);
        contractResolver = ContractResolverIface(resolverManager.getResolver());
        owner = msg.sender;
        assert(msg.sender == getOwner());

        ALLOWED_TOKENS = getConst().ALLOWED_TOKENS();
        OR_RESOLVER = getConst().OR_RESOLVER();
    }


    function getContract(bytes32 _contract_name) internal
    constant
    updateResolver
    returns (address _contract)
    {
        _contract = getContract(_contract_name, true);
    }


    function getConst() internal
    constant
    updateResolver
    returns (ConstantsStore _constants)
    {
        _constants = ConstantsStore(getContract(S_CONSTANTS, true));
        assert(_constants != address(0));
    }

    function getContract(bytes32 _contract_name, bool _should_assert) internal
    constant
    updateResolver
    returns (address _contract)
    {
        _contract = contractResolver.getContractAddress(_contract_name);
        if (_should_assert) assert(_contract != address(0));
    }

    function getContractName(address _contract_address) internal
    constant
    updateResolver
    returns (bytes32 _contract_name)
    {
        _contract_name = contractResolver.getContractName(_contract_address);
    }

    function getOwner() internal
    constant
    updateResolver
    returns (address _owner) {
        _owner = owner;
    }

    function isContractInResolver() internal
    constant
    updateResolver
    returns (bool _is_contract_in_resolver) {
        bytes32 _contract_name = getContractName(msg.sender);
        _is_contract_in_resolver = _contract_name != 0x0;
    }

    function getAllowedTokens() internal
    constant
    updateResolver
    returns (address[] _allowed_tokens)
    {
        uint256 num_allowed = contractResolver.getAllowedTokensCount();
        address[] memory allowed_tokens = new address[](num_allowed);
        for (uint256 i = 0; i < num_allowed; i++)
        {
            allowed_tokens[i] = contractResolver.getAllowedToken(i);
        }
        _allowed_tokens = allowed_tokens;
    }
}
