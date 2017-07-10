pragma solidity ^0.4.11;

import './EmployeesCtrlIface.sol';
import '../ownership/HasNoFunds.sol';
import '../stores/EmployeesStoreIface.sol';
import '../resolver/ResolverClient.sol';

contract EmployeesCtrl is EmployeesCtrlIface, ResolverClient, HasNoFunds {
    bytes32 private S_EMPLOYEES;
    bytes32 private C_EMPLOYEES;
    bytes32 private C_PAYMENTS;
    bytes32 private A_PAYROLL;


    function EmployeesCtrl(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        S_EMPLOYEES = getConst().S_EMPLOYEES();
        C_EMPLOYEES = getConst().C_EMPLOYEES();
        C_PAYMENTS = getConst().C_PAYMENTS();
        A_PAYROLL = getConst().A_PAYROLL();
    }


    function addEmployee(address _account, address[] _allowed_tokens, uint256 _salary) public
    ifSenderIs(A_PAYROLL)
    {
        require(_account != address(0));
        assert(EmployeesStoreIface(getContract(S_EMPLOYEES)).addEmployee(_account, _allowed_tokens, _salary));
    }


    function removeEmployee(uint256 _employee_id) public
    ifSenderIs(A_PAYROLL)
    {
        assert(EmployeesStoreIface(getContract(S_EMPLOYEES)).removeEmployee(_employee_id));
    }


    function getEmployeeCount() public constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _employee_count)
    {
        _employee_count = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeCount();
    }


    function getEmployee(uint256 _employee_id) public constant
    ifSenderIs(A_PAYROLL)
    returns (address _account, uint _salary, uint _removal_ts, uint _start_ts)
    {
        (_account, _salary, _removal_ts, _start_ts) = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployee(_employee_id);
    }


    function getEmployeeSalaryHistoryCount(uint256 _employee_id) public constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _salary_history_count)
    {
        _salary_history_count = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeSalaryHistoryCount(_employee_id);
    }


    function isActiveEmployee(uint256 _employee_id) public constant
    ifSenderIs(A_PAYROLL)
    returns (bool _is_active)
    {
        _is_active = _isActiveEmployee(_employee_id);
    }


    function setEmployeeSalary(uint256 _employee_id, uint256 _usd_salary) public
    ifSenderIs(A_PAYROLL)
    {
        require(isActiveEmployee(_employee_id));
        assert(EmployeesStoreIface(getContract(S_EMPLOYEES)).setEmployeeSalary(_employee_id, _usd_salary));
    }


    function getEmployeeSalary(uint256 _employee_id) public
    constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _salary)
    {
        _salary = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeSalary(_employee_id);
    }


    function getEmployeeSalaryAt(uint256 _employee_id, uint256 _at_time) public
    constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _salary)
    {
        require(_at_time != 0);
        _salary = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeSalaryAt(_employee_id, _at_time);
    }


    function getAllowedTokensCount(uint256 _employee_id) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _dist_count)
    {
        _dist_count = EmployeesStoreIface(getContract(S_EMPLOYEES)).getAllowedTokensCount(_employee_id);
    }


    function getAllowedTokenAndDist(uint256 _employee_id, uint256 _ind) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (address _token, uint256 _dist)
    {
        (_token, _dist) = EmployeesStoreIface(getContract(S_EMPLOYEES)).getAllowedTokenAndDist(_employee_id, _ind);
    }


    function getDistribution(uint256 _employee_id, address _token) public
    constant
    ifSenderIs(C_PAYMENTS)
    returns (uint256 _dist)
    {
        _dist = EmployeesStoreIface(getContract(S_EMPLOYEES)).getDistribution(_employee_id, _token);
    }


    function setDistribution(address _e_adr, address[] _tokens, uint256[] _distribution) public
    ifSenderIs(A_PAYROLL)
    {
        uint256 total_dist = 0;
        for (uint256 i = 0; i < _distribution.length; i++) total_dist = total_dist + _distribution[i];
        require(total_dist == 100);
        require(contractResolver.isAllowedTokens(_tokens));
        if (!EmployeesStoreIface(getContract(S_EMPLOYEES)).setDistribution(_e_adr, _tokens, _distribution)) revert();
    }


    function _isActiveEmployee(uint256 _employee_id) public
    returns (bool _is_active)
    {
        var ( , , removal_ts, start_ts) = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployee(_employee_id);
        if (start_ts == 0) return false;
        _is_active = removal_ts == 0;
    }


    /*
    function getSalariesSummed() public
    constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _salaries_summed) {
        uint256 _salaries_summed = 0;
        uint256 employee_count_ = EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeCount();
        for (uint256 i_ = 1; i_ <= employee_count_; i_++) {
            _salaries_summed_usd = _salaries_summed_usd + EmployeesStoreIface(getContract(S_EMPLOYEES)).getEmployeeSalary(i_);
        }
    }
    */
}
