pragma solidity ^0.4.11;

import './HasNoEther.sol';
import './HasNoTokens.sol';

contract HasNoFunds is HasNoEther, HasNoTokens { }
