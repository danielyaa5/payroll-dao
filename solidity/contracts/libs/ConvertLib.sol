pragma solidity ^0.4.11;

library ConvertLib{
	function convert(uint256 _amt, uint256 _conversion_rate)
    returns (uint256 _converted_amt)
    {
        _converted_amt = _amt * _conversion_rate;
    }
}
