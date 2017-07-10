pragma solidity ^0.4.11;


contract PayrollIface {


    /* ---------------------------------------EMPLOYEES---------------------------------------*/
    // ONLY ADMIN
    function addEmployee(address _account, address[] _allowed_tokens, uint _salary) public;
    // ONLY ADMIN
    function setEmployeeSalary(uint _employee_id, uint _yearly_usd_salary) public;
    // ONLY ADMIN
    function removeEmployee(uint _employee_id) public;
    // ONLY ADMIN
    function getEmployee(uint _employee_id) public constant
        returns (address _account, uint _salary, uint _removal_ts, uint _start_ts);
    // ONLY ADMIN
    function getEmployeeCount() public constant returns (uint _employee_count);
    // ONLY ADMIN
    function getEmployeeSalary(uint _employee_id) public constant returns (uint _salary);
    // ONLY ADMIN
    function getEmployeeSalaryAt(uint _employee_id, uint _at_time) public constant returns (uint _salary);
    // ONLY ADMIN
    function isActiveEmployee(uint _employee_id) public constant returns (bool _active);
    // ONLY EMPLOYEE (once per 6 months)
    function setDistribution(address[] _tokens, uint[] _distribution) public;


    /* -----------------------------------------FUNDS-----------------------------------------*/
    // ONLY ADMIN
    function addEthFunds() public payable;
    // ONLY ADMIN
    function scapeHatch() public;
    // ONLY ORACLE
    function setExchangeRate(address _token, uint256 _atoms_per_usd) public;
    // ONLY EMPLOYEES
    function withdrawEthFunds() public;
    // ONLY ALLOWED TOKENS
    function addTokenFunds(address _from, uint _value, address _token, bytes32 _extra_data) public returns (bool _success);
    // ONLY ALLOWED TOKENS
    function tokenFallback(address _from, uint _value, bytes32 _extra_data) public returns (bool _success);


    /* ----------------------------------------PAYMENTS----------------------------------------*/
    // ONLY ADMIN
    function calculatePayrollBurnrate() public constant returns (uint _burnrate); // Monthly usd amount spent in salaries
    // ONLY ADMIN
    function calculatePayrollRunway() public constant returns (uint _runway); // Days until the contract can run out of funds
    // ONLY EMPLOYEE (once per month)
    function payday(uint _employee_id) public;
}
