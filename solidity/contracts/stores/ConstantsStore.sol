pragma solidity ^0.4.11;

import '../ownership/HasNoFunds.sol';

contract ConstantsStore is HasNoFunds {

    // storage contract names
    bytes32 public constant S_FUNDS = 's:funds';
    bytes32 public constant S_EMPLOYEES = 's:employees';
    bytes32 public constant S_PAYMENTS = 's:payments';
    bytes32 public constant S_CONSTANTS = 's:constants';
    // controller contract names
    bytes32 public constant C_FUNDS = 'c:funds';
    bytes32 public constant C_EMPLOYEES = 'c:employees';
    bytes32 public constant C_PAYMENTS = 'c:payments';
    // other contract names
    bytes32 public constant A_PAYROLL = 'a:payroll';

    // groups
    bytes32 public constant ADMINS = 'admins';
    bytes32 public constant NS_ADMINS = 'ns_admins';
    bytes32 public constant PAUSE_ADMINS = 'pause_admins';
    bytes32 public constant EMPLOYEES = 'employees';
    bytes32 public constant ALLOWED_TOKENS = 'allowed_tokens';
    bytes32 public constant ORACLES = 'oracles';

    // modifier overriders
    bytes32 public constant OR_RESOLVER = 'or_resolver';


    // setDistribution rate limit
    uint256 public constant SET_DIST_CALLS = 1;
    uint256 public constant SET_DIST_TIME = 30 days * 6;
    bytes32 public constant SET_DIST = 'setDistribution';

    // payday rate limit
    uint256 public constant PAYDAY_CALLS = 1;
    uint256 public constant PAYDAY_TIME = 30 days;
    bytes32 public constant PAYDAY = 'PAYDAY';

    // funding
    bytes32 public constant ETH = 'ETH';
    bytes32 public constant USD = 'USD';
    address public constant ETH_ADR = address(0);
}
