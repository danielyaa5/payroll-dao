'use strict';

// npm dep
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const debug = require('debug')('contract-tests:PayrollApp');

// local dep
const config = require('../jslib/config');
const $ = require('../jslib/utils');

// contract deps
const AwesomeToken = $.Contracts.AwesomeToken;
const UsdToken = $.Contracts.UsdToken;
const PayrollApp = $.Contracts.PayrollApp;


// setup
chai.use(chaiAsPromised);
const expect = chai.expect;
const assert = chai.assert;
const web3 = $.web3;
const invalid_opcode_err = /invalid opcode/;

contract('PayrollApp', (accounts) => {
    const owners = {payrollApp: accounts[0], awesomeToken: accounts[1], usdToken: accounts[2]};
    const emp_acc = accounts[3];
    const init_sal = 2 * 100 * 1000;
    const allowed_tokens = [owners.awesomeToken, owners.awesomeToken];

    let payrollApp;
    const deploy = $.deployAll({owners}).then(() => $.Contracts.PayrollApp.deployed()).then((inst) => payrollApp = inst);
    it('should deploy successfully', () => assert.isFulfilled(deploy));

    it('should successfully call addEmployee',
        () => assert.isFulfilled(payrollApp.addEmployee(emp_acc, allowed_tokens, init_sal)));

    it('should now have one employee', () => assert.becomes(payrollApp.getEmployeeCount().then(c => c.toNumber()), 1));

    let employee;
    const eid = 0;
    it('should now be able to call getEmployee on eid = 0',
        () => assert.isFulfilled(payrollApp.getEmployee(eid)).then(e => employee = e));

    it('should have returned an employee with the correct account address, salary, removal time, and start time', () => {
        const employee_address = employee[0];
        const employee_salary = employee[1];
        const employee_removal_ts = employee[2];
        const employee_creation_ts = employee[3].toNumber();
        assert.equal(employee_address, emp_acc, 'Employee address incorrect');
        assert.equal(employee_salary, init_sal, 'Employee salary is incorrect');
        assert.equal(employee_removal_ts, 0, 'Employee removal time is incorrect');
        assert.closeTo(employee_creation_ts, $.timeSecs(), 1, 'Employee start time is incorrect');
    });

    it('should call getEmployeeSalary successfully and confirm the salary returned by getEmployee',
        () => assert.becomes(payrollApp.getEmployeeSalary(eid).then(s => s.toNumber()), init_sal));

    const new_sal = 3 * 100 * 1000;
    it('should successfully call setSalary on the new employee',
        () => assert.isFulfilled(payrollApp.setEmployeeSalary(eid, new_sal)));

    it('should now return the updated salary when getEmployee is called',
        () => assert(payrollApp.getEmployee(eid).then(e => e[1])), new_sal);

    it('should getEmployeeSalary should also confirm the new salary',
        () => assert.becomes(payrollApp.getEmployeeSalary(eid).then(s => s.toNumber()), new_sal));

    it('Should throw invalid opcode error when employee calls payrollApp.addEmployee',
        () => assert.isRejected(payrollApp.addEmployee(
            emp_acc, [owners.awesomeToken, owners.awesomeToken], init_sal, {from: emp_acc})
            , invalid_opcode_err));

    it('Should throw invalid opcode error when employee calls payrollApp.getEmployeeCount',
        () => assert.isRejected(payrollApp.getEmployeeCount({from: emp_acc}), invalid_opcode_err));

    it('Should throw invalid opcode error when employee calls payrollApp.getEmployee',
        () => assert.isRejected(payrollApp.getEmployee(eid, {from: emp_acc}), invalid_opcode_err));

    it('Should throw invalid opcode error when employee calls payrollApp.getEmployeeSalary',
        () => assert.isRejected(payrollApp.getEmployeeSalary(eid, {from: emp_acc}), invalid_opcode_err));

    it('Should throw invalid opcode error when employee calls payrollApp.setEmployeeSalary',
        () => assert.isRejected(payrollApp.setEmployeeSalary(eid, new_sal, {from: emp_acc}), invalid_opcode_err));
});
