pragma solidity ^0.4.11;

import './AcGroups.sol';

contract AcRateLimits is AcGroups {
    mapping(address => mapping(bytes32 => mapping(address => uint256[]))) private RateLimitMap;

    /*
        * WARNING: This isn't safe for small time periods, estimated to be safe for time periods >> 900 seconds.
        Where 900 seconds is the miner manipulable
        * NOTE: This scopes rate limits to a single contract, i.e. one contract has access only to it's rl_groups
    */
    function rateLimit(address _user, uint256 _num_calls, uint256 _time_period, bytes32 _rl_group) public
    returns (bool _is_rate_limited)
    {
        uint256 curr_num_calls = 0;
        for (uint256 i = RateLimitMap[msg.sender][_rl_group][_user].length - 1; i > 0; i--)
        {
            if (RateLimitMap[msg.sender][_rl_group][_user][i] < now - _time_period) break;
            curr_num_calls = curr_num_calls + 1;
        }

        _is_rate_limited = curr_num_calls + 1 > _num_calls;
    }
}
