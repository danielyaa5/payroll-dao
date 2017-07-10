pragma solidity ^0.4.11;


library StrLib {
    function indexOfStr(string[] _arr, string _search) internal
    returns (int256 _ind)
    {
        _ind = -1;
        for(uint256 i = 0; i < _arr.length; i++) {
           if (equal(_arr[i],_search)) {
                _ind = int256(i);
                break;
           }
        }
    }


    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive number if `_b` is smaller.
    function compare(string _a, string _b)
    returns (int)
    {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
        if (a[i] < b[i])
        return -1;
        else if (a[i] > b[i])
        return 1;
        if (a.length < b.length)
        return -1;
        else if (a.length > b.length)
        return 1;
        else
        return 0;
    }


    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b)
    returns (bool _is_equal) {
        _is_equal = compare(_a, _b) == 0;
    }


    function compare(bytes32 a, bytes32 b)
    returns (bool _equal)
    {
        _equal = true;
        for (uint256 i = 0; i < a.length; i++)
        {
            if (a[i] != b[i]) return false;
        }
    }
}
