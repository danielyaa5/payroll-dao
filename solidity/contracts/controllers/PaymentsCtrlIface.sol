pragma solidity ^0.4.11;

contract PaymentsCtrlIface {
    function payday(uint256 _employee_id) public;


    function calculatePayrollBurnrate() public
    constant
    returns (uint256 _burnrate);

    function calculatePayrollRunway() public
    constant
    returns (uint256 _runway);


    function calculatePeriodsOwed(uint256 _last_pay_ts, uint256 _removal_ts, uint256 _start_ts) private
    constant
    returns (uint256 _owed_pay_periods);


    function calculatePayOwedNow(uint256 _eid, uint256 _periods_owed, uint256 _salary, uint256 _start_ts) private
    constant
    returns (uint256 _amt_owed);


    function getPayments(uint256 _employee_id, uint256 _last_pay_id, uint256 _pay_owed_now) private
    constant
    returns (address[] _allowed_tokens, uint256[] _payments);


    function analyzeCosts() private
    constant
    returns (uint256 _pay_owed_now, uint256[] _cost_for_day);
}
