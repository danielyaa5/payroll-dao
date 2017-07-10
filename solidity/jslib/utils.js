'use strict';

// npm deps
const Web3 = require('web3');
const _ = require('lodash');

// local deps
const config = require('./config');

// setup
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));


class utils {
    static get web3() {
        return web3;
    }

    static owners() {
        throw Error('The owners prop has not added to Utils yet');
    }

    static deployer() {
        throw Error('The deployer prop has not added to Utils yet');
    }

    static Contracts() {
        throw Error('The Contracts prop has not added to Utils yet');
    }

    static timeSecs() { return Math.round(new Date().getTime()/1000); }

    static async deployAll(opts) {
        const owners = _.defaultsDeep(opts.owners, this.owners);

        // Libs
        await this.deployer.deploy(this.Contracts.ConvertLib, { from: owners.payrollApp });
        await this.deployer.deploy(this.Contracts.StrLib, { from: owners.payrollApp });
        await this.deployer.deploy(this.Contracts.SafeMath, { from: owners.payrollApp });
        await this.deployer.link(this.Contracts.ConvertLib, [this.Contracts.FundsStore, this.Contracts.FundsCtrl]);
        await this.deployer.link(this.Contracts.StrLib, [this.Contracts.ContractResolver, this.Contracts.FundsCtrl]);
        await this.deployer.link(this.Contracts.SafeMath, [this.Contracts.PaymentsCtrl]);

        // Tokens
        await this.deployer.deploy(this.Contracts.AwesomeToken, { from: owners.awesomeToken });
        await this.deployer.deploy(this.Contracts.UsdToken, { from: owners.usdToken });

        // Resolver
        await this.deployer.deploy(this.Contracts.ConstantsStore, { from: owners.payrollApp });
        await this.deployer.deploy(this.Contracts.ContractResolver, this.Contracts.ConstantsStore.address, { from: owners.payrollApp });
        const contractResolver = await this.Contracts.ContractResolver.deployed();
        await this.deployer.deploy(this.Contracts.ResolverManager, contractResolver.address, { from: owners.payrollApp });
        const resolverManager = await this.Contracts.ResolverManager.deployed();

        // Stores
        await this.deployer.deploy(this.Contracts.EmployeesStore, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.S_EMPLOYEES, this.Contracts.EmployeesStore.address);
        await this.deployer.deploy(this.Contracts.FundsStore, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.S_FUNDS, this.Contracts.FundsStore.address);
        await this.deployer.deploy(this.Contracts.PaymentsStore, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.S_PAYMENTS, this.Contracts.PaymentsStore.address);

        // Controllers
        await this.deployer.deploy(this.Contracts.EmployeesCtrl, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.C_EMPLOYEES, this.Contracts.EmployeesCtrl.address);
        await this.deployer.deploy(this.Contracts.FundsCtrl, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.C_FUNDS, this.Contracts.FundsCtrl.address);
        await this.deployer.deploy(this.Contracts.PaymentsCtrl, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.C_PAYMENTS, this.Contracts.PaymentsCtrl.address);

        // App
        await this.deployer.deploy(this.Contracts.PayrollApp, resolverManager.address, { from: owners.payrollApp });
        await contractResolver.registerContract(config.A_PAYROLL, this.Contracts.PayrollApp.address);
    }
}


/* ----------------------------------- Default Export -----------------------------------*/
module.exports = utils;
