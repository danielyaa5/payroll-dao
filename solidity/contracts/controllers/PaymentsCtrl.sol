pragma solidity ^0.4.11;

import './PaymentsCtrlIface.sol';
import '../ownership/HasNoFunds.sol';
import '../resolver/ResolverClient.sol';
import '../stores/PaymentsStoreIface.sol';
import '../controllers/FundsCtrlIface.sol';
import '../installed/zeppelin/SafeMath.sol';
import '../controllers/EmployeesCtrlIface.sol';


contract PaymentsCtrl is PaymentsCtrlIface, ResolverClient, HasNoFunds {
    using SafeMath for uint;

    bytes32 private S_PAYMENTS;
    bytes32 private C_EMPLOYEES;
    bytes32 private C_FUNDS;
    bytes32 private A_PAYROLL;
    address private ETH_ADR;
    address[] private ALLOWED_TOKENS;

    function PaymentsCtrl(address _resolver_manager) ResolverClient(_resolver_manager)
    {
        S_PAYMENTS = getConst().S_PAYMENTS();
        C_EMPLOYEES = getConst().C_EMPLOYEES();
        C_FUNDS = getConst().C_FUNDS();
        A_PAYROLL = getConst().A_PAYROLL();
        ETH_ADR = getConst().ETH_ADR();

        for (uint256 i = 0; i < contractResolver.getAllowedTokensCount(); i++)
        {
            ALLOWED_TOKENS.push(contractResolver.getAllowedToken(i));
        }
    }


    function payday(uint256 _employee_id) public
    ifSenderIs(A_PAYROLL)
    {
        var (e_adr, salary, removal_ts, start_ts) = EmployeesCtrlIface(getContract(C_EMPLOYEES))
                                                        .getEmployee(_employee_id);
        var (last_pay_id, , last_pay_ts) = PaymentsStoreIface(getContract(S_PAYMENTS)).getLastPayment(_employee_id);
        uint256 periods_owed = calculatePeriodsOwed(last_pay_ts, removal_ts, start_ts);
        uint256 pay_owed_now = calculatePayOwedNow(_employee_id, periods_owed, salary, start_ts);

        if(!PaymentsStoreIface(getContract(S_PAYMENTS)).payday(_employee_id, pay_owed_now)) revert();

        var (allowed_tokens, payments) = getPayments(_employee_id, last_pay_id, pay_owed_now);
        FundsCtrlIface(getContract(C_FUNDS)).sendFunds(e_adr, allowed_tokens, payments);

    }


    function calculatePayrollBurnrate() public
    constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _burnrate)
    {
        uint256 payment_count = PaymentsStoreIface(getContract(S_PAYMENTS)).getPaymentsCount();
        for (uint256 payment_id = payment_count; payment_id > 0; payment_id--)
        {
            var (, total_usd, time) = PaymentsStoreIface(getContract(S_PAYMENTS)).getPayment(payment_id);
            if (uint256(now).sub(time) > 30 days) break; // Payments are ordered by time so no reason to keep going here
            _burnrate = _burnrate + total_usd; // calculate the payment in usd
        }
    }

    /*
        * Calculates the number of days of funding left
        * Assumption: Since money now is worth more than money later, assume if employee can they will withdraw now
        * Step 1: Calculate pay owed now and then calculate pay owed for each day of 30 day period.
        * Step 2: Calculate days of funds available by seeing how long you can sub payment day from total funds
        while (funds > 0; runway = -1; runway++) funds -= runway==0 ? pay_owed_now : cost_for_day[(runway % 30) - 1]
    */
    function calculatePayrollRunway() public
    constant
    ifSenderIs(A_PAYROLL)
    returns (uint256 _runway)
    {
        var (pay_owed_now, cost_for_day) = analyzeCosts();

        // while (funds > 0; runway = -1; runway++) funds -= runway==0 ? pay_owed_now : cost_for_day[(runway % 30) - 1]
        uint256 total_funds = FundsCtrlIface(getContract(C_FUNDS)).getTotalFunds();
        while (total_funds > 0)
        {
            if (_runway == 0)
            {
                total_funds = total_funds - pay_owed_now;
            }
            else
            {
                total_funds = total_funds.sub((cost_for_day[(_runway % 30).sub(1)]));
            }
            _runway = _runway + 1;
        }
    }


    /*
        * Time Worked (if active) = now - Start_Time
        * Time Worked (if removed) = Removal_Time - Start_Time
        * Pay Periods While Working = floor( Time_Worked / 30 days ) + 1
        * Periods Paid (if has been paid ) = floor( Last_Payment_Time - Start_Time ) + 1
        * Periods Paid (if never paid ) = 0
        * Pay Periods Owed Payment For = Pay Periods While Working - Periods Paid
    */
    function calculatePeriodsOwed(uint256 _last_pay_ts, uint256 _removal_ts, uint256 _start_ts) private
    constant
    returns (uint256 _owed_pay_periods)
    {
        bool has_been_paid = _last_pay_ts > 0;
        bool is_active = _removal_ts == 0 && _start_ts != 0;
        uint256 time_since_start_and_last_pay = _last_pay_ts.sub(_start_ts);
        uint256 time_working = is_active ? now.sub(_start_ts) : _removal_ts.sub(_start_ts);
        uint256 pay_periods_while_working = (time_working.div(30 days)).add(1);
        uint256 paid_periods = has_been_paid ? (time_since_start_and_last_pay.div(30 days)).add(1) : 0;
        _owed_pay_periods = pay_periods_while_working.sub(paid_periods);
    }


    /*
        * Given the number of pay periods the employee is owed, determine how much they should get paid.
        * Owed = Salary@Period1 + Salary@Period2 + Salary@Period3 + ... + Salary@PeriodN
    */
    function calculatePayOwedNow(uint256 _eid, uint256 _periods_owed, uint256 _salary, uint256 _start_ts) private
    constant
    returns (uint256 _amt_owed)
    {
        _amt_owed = 0;
        for (uint256 i = 1; i <= _periods_owed; i++)
        {
            uint256 period_salary;
            if (i == _periods_owed.add(1))
            {
                period_salary = _salary;
            }
            else
            {
                period_salary = EmployeesCtrlIface(getContract(C_EMPLOYEES))
                                    .getEmployeeSalaryAt(_eid, _start_ts.add(uint256(30 days).mul(i)));
            }
            _amt_owed = _amt_owed.add(period_salary);
        }
    }


    function getPayments(uint256 _employee_id, uint256 _last_pay_id, uint256 _pay_owed_now) private
    constant
    returns (address[] _allowed_tokens, uint256[] _payments)
    {

        // (usd * percent_dist * usd_to_token)/100
        address allowed_token;
        uint256 allowed_tokens_count = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getAllowedTokensCount(_employee_id);
        _payments = new uint256[](allowed_tokens_count);
        _allowed_tokens = new address[](allowed_tokens_count);
        uint256 dist = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getDistribution(_employee_id, ETH_ADR);
        _payments[0] = (_pay_owed_now * dist * FundsCtrlIface(getContract(C_FUNDS)).getExchangeRate(ETH_ADR)) / 100;
        PaymentsStoreIface(getContract(S_PAYMENTS)).addTokenAndDistToPay(_last_pay_id + 1, allowed_token, dist);
        for(uint256 i = 0; i < allowed_tokens_count; i++)
        {
            (allowed_token, dist) = EmployeesCtrlIface(getContract(C_EMPLOYEES))
                                        .getAllowedTokenAndDist(_employee_id, i);
            _payments[i+1] = (_pay_owed_now.mul(dist).mul(FundsCtrlIface(getContract(C_FUNDS))
                                                            .getExchangeRate(allowed_token))).div(100);
            _allowed_tokens[i] = allowed_token;
            PaymentsStoreIface(getContract(S_PAYMENTS)).addTokenAndDistToPay(_last_pay_id + 1, allowed_token, dist);
        }
    }


    function analyzeCosts() private
    constant
    returns (uint256 _pay_owed_now, uint256[] _cost_for_day)
    {
        _cost_for_day = new uint256[](30);
        uint256 employee_count = EmployeesCtrlIface(getContract(C_EMPLOYEES)).getEmployeeCount();
        for (uint256 employee_id = 0; employee_id < employee_count; employee_id++)
        {
            var (, , salary , removal_ts, start_ts) = EmployeesCtrlIface(getContract(C_EMPLOYEES))
                                                        .getEmployee(employee_id);
            var (, , last_pay_ts) = PaymentsStoreIface(getContract(S_PAYMENTS)).getLastPayment(employee_id);
            uint256 days_since_last_pay = (now.sub(last_pay_ts)).div(1 days);
            if (days_since_last_pay > 30)
            {
                _cost_for_day[0] = _cost_for_day[0].add(salary);
            }
            else
            {
                uint256 periods_owed = calculatePeriodsOwed(last_pay_ts, removal_ts, start_ts);
                _pay_owed_now = _pay_owed_now.add(calculatePayOwedNow(employee_id, periods_owed, salary, start_ts));
                _cost_for_day[days_since_last_pay] = _cost_for_day[days_since_last_pay].add(salary);
            }
        }

    }
}
