pragma solidity ^0.4.11;

import './EmployeesStoreIface.sol';
import '../ownership/HasNoFunds.sol';
import '../resolver/ResolverClient.sol';

contract EmployeesStore is EmployeesStoreIface, ResolverClient, HasNoFunds {
    bytes32 private C_EMPLOYEES;
    bytes32 private EMPLOYEES;
    address private ETH_ADR;

    struct Salary {
        uint256 ts;
        uint256 amt;
    }
    struct Employee {
        address account_address;
        mapping(uint256 => Salary) salary_history;
        uint256 salary_history_count;
        address[] allowed_tokens;
        mapping(address => uint256) DistributionMap;
        uint256 removal_ts;
        uint256 start_ts;
    }
    Employee[] private employees;
    mapping(address => uint256) private employee_address_to_id;


    function EmployeesStore(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        C_EMPLOYEES = getConst().C_EMPLOYEES();
        EMPLOYEES = getConst().EMPLOYEES();
        ETH_ADR = getConst().ETH_ADR();
    }


    function addEmployee(address _account, address[] _allowed_tokens, uint256 _salary) public
    ifSenderIs(C_EMPLOYEES)
    returns (bool _success)
    {
        Employee memory e;
        e.account_address = _account;
        e.allowed_tokens = _allowed_tokens;
        e.removal_ts = 0;
        e.start_ts = now;
        e.salary_history_count = 1;
        employees.push(e);
        employees[employees.length - 1].DistributionMap[ETH_ADR] = 100;
        employees[employees.length - 1].salary_history[0] = Salary(now, _salary);
        employee_address_to_id[_account] = employees.length - 1;
        _success = contractResolver.addGroupie(EMPLOYEES, _account);

        _success = true;
    }


    function removeEmployee(uint256 _employee_id) public
    ifSenderIs(C_EMPLOYEES)
    returns (bool _success)
    {
        employees[_employee_id].removal_ts = now;
        _success = contractResolver.removeGroupie(EMPLOYEES, employees[_employee_id].account_address);
    }


    function getEmployee(uint256 _employee_id) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (address _account, uint _salary, uint _removal_ts, uint _start_ts)
    {
        _account = employees[_employee_id].account_address;
        _salary = employees[_employee_id].salary_history[employees[_employee_id].salary_history_count - 1].amt;
        _removal_ts = employees[_employee_id].removal_ts;
        _start_ts = employees[_employee_id].start_ts;
    }


    function getEmployeeCount() public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _employee_count)
    {
        _employee_count = employees.length;
    }


    function getEmployeeSalary(uint256 _employee_id) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _salary)
    {
        _salary = employees[_employee_id].salary_history[employees[_employee_id].salary_history_count - 1].amt;
    }


    function getEmployeeSalaryAt(uint256 _employee_id, uint256 _at_time) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _salary)
    {
        require(employees[_employee_id].salary_history[0].ts <= _at_time);
        for (uint256 i = employees[_employee_id].salary_history_count - 1; i > 0; i--)
        {
            if (employees[_employee_id].salary_history[i].ts <= _at_time)
            {
                _salary = employees[_employee_id].salary_history[i].amt;
            }
        }
    }


    function getEmployeeSalaryHistoryCount(uint256 _employee_id) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _salary_history_count)
    {
        _salary_history_count = employees[_employee_id].salary_history_count;
    }


    function getRemovalTimestamp(uint256 _employee_id) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _removal_ts)
    {
        _removal_ts = employees[_employee_id].removal_ts;
    }


    function setEmployeeSalary(uint256 _employee_id, uint256 _salary)
    ifSenderIs(C_EMPLOYEES)
    returns (bool _success)
    {
        employees[_employee_id].salary_history[employees[_employee_id].salary_history_count].ts = now;
        employees[_employee_id].salary_history[employees[_employee_id].salary_history_count].amt = _salary;
        employees[_employee_id].salary_history_count += 1;
        _success = true;
    }


    function getAllowedTokensCount(uint256 _employee_id) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _allowed_token_count)
    {
        _allowed_token_count = employees[_employee_id].allowed_tokens.length;
    }


    function getAllowedTokenAndDist(uint256 _employee_id, uint256 _ind) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (address _token, uint256 _dist)
    {
        _token = employees[_employee_id].allowed_tokens[_ind];
        _dist = employees[_employee_id].DistributionMap[_token];
    }


    function getDistribution(uint256 _employee_id, address _token) public
    constant
    ifSenderIs(C_EMPLOYEES)
    returns (uint256 _dist)
    {
        _dist = employees[_employee_id].DistributionMap[_token];
    }


    function setDistribution(address _e_adr, address[] _tokens, uint256[] _distribution) public
    ifSenderIs(C_EMPLOYEES)
    returns (bool _success)
    {
        for (uint256 i = 0; i < _tokens.length; i++)
        {
            employees[employee_address_to_id[_e_adr]].DistributionMap[_tokens[i]] = _distribution[i];
        }
        _success = true;
    }
}
