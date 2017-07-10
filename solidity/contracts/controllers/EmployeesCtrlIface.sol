pragma solidity ^0.4.11;

contract EmployeesCtrlIface {
    function addEmployee(address _account, address[] _allowed_tokens, uint256 _salary) public;


    function removeEmployee(uint256 _employee_id) public;


    function getEmployeeCount() public constant
    returns (uint256 _employee_count);


    function getEmployee(uint256 _employee_id) public constant
    returns (address _account, uint _salary, uint _removal_ts, uint _start_ts);


    function getEmployeeSalaryHistoryCount(uint256 _employee_id) public constant
    returns (uint256 _salary_history_count);


    function isActiveEmployee(uint256 _employee_id) public constant
    returns (bool _is_active);


    function setEmployeeSalary(uint256 _employee_id, uint256 _usd_salary) public;


    function getEmployeeSalary(uint256 _employee_id) public
    constant
    returns (uint256 _salary);


    function getEmployeeSalaryAt(uint256 _employee_id, uint256 _at_time) public
    constant
    returns (uint256 _salary);


    function getAllowedTokensCount(uint256 _employee_id) public
    constant
    returns (uint256 _dist_count);


    function getAllowedTokenAndDist(uint256 _employee_id, uint256 _ind) public
    constant
    returns (address _token, uint256 _dist);


    function getDistribution(uint256 _employee_id, address _token) public
    constant
    returns (uint256 _dist);


    function setDistribution(address _e_adr, address[] _tokens, uint256[] _distribution) public;

    function _isActiveEmployee(uint256 _employee_id) public
    returns (bool _is_active);
}
