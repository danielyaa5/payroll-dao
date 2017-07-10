'use strict';

// local deps
const $ = require('../jslib/utils');
const config = require('../jslib/config');

// contract deps
const Contracts = {};
Contracts.ConvertLib = artifacts.require('./libs/ConvertLib.sol');
Contracts.StrLib = artifacts.require('./libs/StrLib.sol');
Contracts.SafeMath = artifacts.require('./installed/zeppelin/SafeMath.sol');

Contracts.AwesomeToken = artifacts.require('./tokens/AwesomeToken.sol');
Contracts.UsdToken = artifacts.require('./tokens/UsdToken.sol');

Contracts.ContractResolver = artifacts.require('./resolver/ContractResolver.sol');
Contracts.ConstantsStore = artifacts.require('./stores/ConstantsStore.sol');
Contracts.ResolverManager = artifacts.require('./resolver/ResolverManager.sol');

Contracts.EmployeesStore = artifacts.require('./stores/EmployeesStore.sol');
Contracts.FundsStore = artifacts.require('./stores/FundsStore.sol');
Contracts.PaymentsStore = artifacts.require('./stores/PaymentsStore.sol');

Contracts.EmployeesCtrl = artifacts.require('./stores/EmployeesCtrl.sol');
Contracts.FundsCtrl = artifacts.require('./stores/FundsCtrl.sol');
Contracts.PaymentsCtrl = artifacts.require('./stores/PaymentsCtrl.sol');

Contracts.PayrollApp = artifacts.require('./PayrollApp.sol');

// setup
const web = $.web3;
const info = web3.eth.getBlock('latest');

module.exports = async function (deployer, network, accounts) {
    const payrollApp = accounts[0];
    const awesomeToken = accounts[1];
    const usdToken = accounts[2];
    const owners = { payrollApp, awesomeToken, usdToken };

    Object.assign($, { deployer, artifacts, accounts, owners, Contracts });

    // await Utils.deployAll();
};
