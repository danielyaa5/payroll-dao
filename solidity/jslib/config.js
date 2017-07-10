'use strict';

const config = {
    S_FUNDS: 's:funds',
    S_EMPLOYEES: 's:employees',
    S_PAYMENTS: 's:payments',
    S_CONSTANTS: 's:constants',
    C_FUNDS: 'c:funds',
    C_EMPLOYEES: 'c:employees',
    C_PAYMENTS: 'c:payments',
    A_PAYROLL: 'a:payroll',
    ADMINS: 'admins',
    NS_ADMINS: 'ns_admins',
    PAUSE_ADMINS: 'pause_admins',
    EMPLOYEES: 'employees',
    ALLOWED_TOKENS: 'allowed_tokens',
    ORACLES: 'oracles',
    OR_RESOLVER: 'or_resolver',
    SET_DIST_CALLS: 1,
    SET_DIST_TIME: 6 * 30 * (24 * 60 * 60), // 6 months in secs
    SET_DIST: 'setDistribution',
    PAYDAY_CALLS: 1,
    PAYDAY_TIME: 30 * (24 * 60 * 60), // 30 days in secs
    PAYDAY: 'PAYDAY',
    ETH: 'ETH',
    USD: 'USD',
    ETH_ADR: 0,
    INVALID_OPCODE: 'VM Exception while processing transaction: invalid opcode'
};

module.exports = config;
