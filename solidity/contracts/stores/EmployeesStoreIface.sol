pragma solidity ^0.4.11;

contract EmployeesStoreIface {
    function addEmployee(address _account, address[] _allowed_tokens, uint256 _salary) public
    returns (bool _success);


    function removeEmployee(uint256 _employee_id) public
    returns (bool _success);


    function getEmployee(uint256 _employee_id) public
    constant
    returns (address _account, uint _salary, uint _removal_ts, uint _start_ts);


    function getEmployeeCount() public
    constant
    returns (uint256 _employee_count);


    function getEmployeeSalary(uint256 _employee_id) public
    constant
    returns (uint256 _salary);


    function getEmployeeSalaryAt(uint256 _employee_id, uint256 _at_time) public
    constant
    returns (uint256 _salary);


    function getEmployeeSalaryHistoryCount(uint256 _employee_id) public
    constant
    returns (uint256 _salary_history_count);


    function getRemovalTimestamp(uint256 _employee_id) public
    constant
    returns (uint256 _removal_ts);


    function setEmployeeSalary(uint256 _employee_id, uint256 _salary)
    returns (bool _success);

    function getAllowedTokensCount(uint256 _employee_id) public
    constant
    returns (uint256 _allowed_token_count);


    function getAllowedTokenAndDist(uint256 _employee_id, uint256 _ind) public
    constant
    returns (address _token, uint256 _dist);


    function getDistribution(uint256 _employee_id, address _token) public
    constant
    returns (uint256 _dist);


    function setDistribution(address _e_adr, address[] _tokens, uint256[] _distribution) public
    returns (bool _success);
}
