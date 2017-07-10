pragma solidity ^0.4.11;

import '../libs/StrLib.sol';
import './ContractResolverIface.sol';
import '../ownership/HasNoFunds.sol';
import '../access_controls/AcPause.sol';
import '../access_controls/AcTokens.sol';
import '../access_controls/AcGroups.sol';
import '../access_controls/AcRateLimits.sol';

contract ContractResolver is ContractResolverIface, HasNoFunds, AcGroups, AcTokens, AcPause, AcRateLimits {
   bytes32 private ADMINS;
   bytes32 private NS_ADMINS;
   bytes32 private S_CONSTANTS;

   event RegisterEvent(bytes32 indexed _contract_name, address indexed _contract_address);
   event UpdateEvent(bytes32 indexed _contract_name, address indexed _new_contract_address);


   function ContractResolver(address _constants) AcGroups(_constants)
   {
      ADMINS = const.ADMINS();
      NS_ADMINS = const.NS_ADMINS();
      S_CONSTANTS = const.S_CONSTANTS();
      GroupsMap[ADMINS][msg.sender] = true;
      GroupsMap[NS_ADMINS][msg.sender] = true;
      registerContract(S_CONSTANTS, _constants);
   }


   function registerContract(bytes32 _contract_name, address _contract_address) public
   onlyGroupie(NS_ADMINS)
   returns (bool _success)
   {
      ContractNameMap[_contract_name] = _contract_address;
      ContractAddressMap[_contract_address] = _contract_name;
      _success = true;
      RegisterEvent(_contract_name, _contract_address);
   }


   function upgradeContract(bytes32 _contract_name, address _new_contract_address) public
   onlyGroupie(NS_ADMINS)
   returns (bool _success)
   {
      if (StrLib.compare(_contract_name, S_CONSTANTS)) {
        const = ConstantsStore(_new_contract_address);
      }
      address old_address = ContractNameMap[_contract_name];
      delete ContractAddressMap[old_address];
      ContractNameMap[_contract_name] = _new_contract_address;
      ContractAddressMap[_new_contract_address] = _contract_name;
      _success = true;
      UpdateEvent(_contract_name, _new_contract_address);
   }


   function getContractAddress(bytes32 _contract_name) public
   constant
   returns (address _contract_address)
   {
      _contract_address = ContractNameMap[_contract_name];
   }


   function getContractName(address _contract_address) public
   constant
   returns (bytes32 _contract_name)
   {
      _contract_name = ContractAddressMap[_contract_address];
   }
}
