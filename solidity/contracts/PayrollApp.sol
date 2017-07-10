pragma solidity ^0.4.11;

import './PayrollIface.sol';
import './ownership/HasNoFunds.sol';
import './resolver/ResolverClient.sol';
import './controllers/FundsCtrlIface.sol';
import './controllers/PaymentsCtrlIface.sol';
import './controllers/EmployeesCtrlIface.sol';
import './installed/zeppelin/token/ERC20.sol';
import './installed/zeppelin/ReentrancyGuard.sol';

contract PayrollApp is PayrollIface, ResolverClient, ReentrancyGuard, HasNoFunds {
    bytes32 private C_EMPLOYEES;
    bytes32 private C_FUNDS;
    bytes32 private C_PAYMENTS;
    bytes32 private S_FUNDS;
    bytes32 private EMPLOYEES;
    bytes32 private ORACLES;
    address private ETH_ADR;

    bytes32 private SET_DIST;
    uint256 private SET_DIST_CALLS;
    uint256 private SET_DIST_TIME;

    bytes32 private PAYDAY;
    uint256 private PAYDAY_CALLS;
    uint256 private PAYDAY_TIME;

    event ScapeHatchEvent();
    event FundsReceivedEvent(address indexed _from, uint256 indexed _amt, address _token);

    modifier onlyEmployeeOrOwner()
    {
        assert(msg.sender == getOwner() || contractResolver.isGroupie(EMPLOYEES, msg.sender));
        _;
    }

    /////////////////////
    //// Constructor ////
    /////////////////////
    function PayrollApp(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        C_EMPLOYEES = getConst().C_EMPLOYEES();
        C_FUNDS = getConst().C_FUNDS();
        C_PAYMENTS = getConst().C_PAYMENTS();
        S_FUNDS = getConst().S_FUNDS();
        EMPLOYEES = getConst().EMPLOYEES();
        ORACLES = getConst().ORACLES();
        ETH_ADR = getConst().ETH_ADR();

        SET_DIST = getConst().SET_DIST();
        SET_DIST_CALLS = getConst().SET_DIST_CALLS();
        SET_DIST_TIME = getConst().SET_DIST_TIME();

        PAYDAY_CALLS = getConst().PAYDAY_CALLS();
        PAYDAY_TIME = getConst().PAYDAY_TIME();
        PAYDAY = getConst().PAYDAY();
    }


    ///////////////////
    //// Employees ////
    ///////////////////
    function addEmployee(address _account_address, address[] _allowed_tokens, uint256 _initial_yearly_salary) public
    onlyAdmin whenActive nonReentrant
    {
        EmployeesCtrlIface(getContract(C_EMPLOYEES))
            .addEmployee(_account_address, _allowed_tokens, _initial_yearly_salary);
    }
    function setEmployeeSalary(uint256 _employee_id, uint256 _yearly_usd_salary) public
    onlyAdmin whenActive nonReentrant
    {
        EmployeesCtrlIface(getContract(C_EMPLOYEES)).setEmployeeSalary(_employee_id, _yearly_usd_salary);
    }

    function getEmployeeSalary(uint256 _employee_id) public
    constant
    onlyAdmin
    returns (uint256 _salary)
    {
        _salary = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getEmployeeSalary(_employee_id);
    }

    function getEmployeeSalaryAt(uint256 _employee_id, uint256 _at_time) public
    constant
    onlyAdmin
    returns (uint256 _salary)
    {
        _salary = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getEmployeeSalaryAt(_employee_id, _at_time);
    }

    function removeEmployee(uint256 _employee_id) public
    onlyAdmin whenActive nonReentrant
    {
        EmployeesCtrlIface(getContract(C_EMPLOYEES)).removeEmployee(_employee_id);
    }
    function getEmployee(uint256 _employee_id) public
    constant
    onlyAdmin
    returns (address _account, uint256 _salary, uint256 _removal_ts, uint256 _start_ts)
    {
        (_account, _salary, _removal_ts, _start_ts) = EmployeesCtrlIface(getContract(C_EMPLOYEES))
                                                        .getEmployee(_employee_id);
    }
    function getEmployeeCount() public
    constant
    onlyAdmin
    returns (uint256 _employee_count)
    {
        _employee_count = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getEmployeeCount();
    }
    function isActiveEmployee(uint256 _employee_id) public
    constant
    onlyAdmin
    returns (bool _active)
    {
        _active = EmployeesCtrlIface(getContract(C_EMPLOYEES)).isActiveEmployee(_employee_id);
    }
    function setDistribution(address[] _tokens, uint256[] _distribution) public // NOTE: callable 1 per 6 months
    onlyGroupie(EMPLOYEES) rateLimit(SET_DIST_CALLS, SET_DIST_TIME, SET_DIST)
    {
        EmployeesCtrlIface(getContract(C_EMPLOYEES)).setDistribution(msg.sender, _tokens, _distribution);
    }


    ///////////////
    //// Funds ////
    ///////////////
    function addEthFunds() public payable
    onlyAdmin whenActive nonReentrant
    {
        FundsCtrlIface(getContract(C_FUNDS)).addEthFunds.value(msg.value)();
        FundsReceivedEvent(msg.sender, msg.value, ETH_ADR);
    }
    function scapeHatch() public
    onlyAdmin whenActive nonReentrant
    {
        FundsCtrlIface(getContract(C_FUNDS)).scapeHatch();
        ScapeHatchEvent();
    }
    function setExchangeRate(address _token, uint256 _atoms_per_usd) public
    onlyGroupie(ORACLES) whenActive nonReentrant
    {
        FundsCtrlIface(getContract(C_FUNDS)).setExchangeRate(_token, _atoms_per_usd);
    }
    function withdrawEthFunds() public
    onlyGroupie(EMPLOYEES)
    {
        FundsCtrlIface(getContract(C_FUNDS)).withdrawEthFunds(msg.sender);
    }
    function addTokenFunds(address _from, uint256 _value, address _token, bytes32) public
    onlyAllowedTokens nonReentrant
    returns (bool _success)
    {
        ERC20(_token).transferFrom(_from, getContract(S_FUNDS), _value);
        FundsCtrlIface(getContract(C_FUNDS)).addTokenFunds(_from, _value, _token);
        FundsReceivedEvent(_from, _value, _token);
        _success = true;
    }
    function tokenFallback(address _from, uint _value, bytes32 _extra_data) public
    returns (bool _success)
    {
        _success = addTokenFunds(_from, _value, msg.sender, _extra_data);
    }


    //////////////////
    //// Payments ////
    //////////////////
    function calculatePayrollBurnrate() public // Monthly (30 days) usd amount spent in salaries
    constant
    onlyAdmin
    returns (uint256 _burnrate)
    {
        _burnrate = PaymentsCtrlIface(getContract(C_PAYMENTS)).calculatePayrollBurnrate();
    }
    function calculatePayrollRunway() public // Days until the contract can run out of funds
    constant
    onlyAdmin
    returns (uint256 _runway)
    {
        _runway = PaymentsCtrlIface(getContract(C_PAYMENTS)).calculatePayrollRunway();
    }
    function payday(uint256 _employee_id) public
    rateLimit(SET_DIST_CALLS, SET_DIST_TIME, SET_DIST) onlyGroupie(EMPLOYEES)
    {
        PaymentsCtrlIface(getContract(C_PAYMENTS)).payday(_employee_id);
    }
}
