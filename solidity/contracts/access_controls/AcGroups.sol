pragma solidity ^0.4.11;

import '../ownership/HasConstants.sol';
import '../installed/zeppelin/ownership/Ownable.sol';

// Access Control Contract
contract AcGroups is Ownable, HasConstants {
    bytes32 private ADMINS;

    mapping (bytes32 => mapping(address => bool)) internal GroupsMap;
    mapping(bytes32 => address) internal ContractNameMap;
    mapping(address => bytes32) internal ContractAddressMap;


    modifier onlyGroupie(bytes32 _group_name)
    {
        assert(GroupsMap[_group_name][msg.sender]);
        _;
    }

    modifier onlyAdmins()
    {
        assert(GroupsMap[ADMINS][msg.sender]);
        _;
    }

    modifier onlyAdminsOrContracts()
    {
        assert(GroupsMap[ADMINS][msg.sender] || ContractAddressMap[msg.sender] != '');
        _;
    }

    function AcGroups(address _constants) HasConstants(_constants) { ADMINS = const.ADMINS(); }

    function addAdmin(address _new_admin) public
    onlyOwner
    returns (bool _success)
    {
        GroupsMap[ADMINS][_new_admin] = true;
        _success = true;
    }

    function removeAdmin(address _removal_admin) public
    onlyOwner
    returns (bool _success)
    {
        GroupsMap[ADMINS][_removal_admin] = false;
        _success = true;
    }

    function addGroupie(bytes32 _group_name, address _new_groupie) public
    onlyAdminsOrContracts
    returns (bool _success)
    {
        GroupsMap[_group_name][_new_groupie] = true;
        _success = true;
    }

    function removeGroupie(bytes32 _group_name, address _removal_groupie) public
    onlyAdminsOrContracts
    returns (bool _success)
    {
        GroupsMap[_group_name][_removal_groupie] = false;
        _success = true;
    }

    function isGroupie(bytes32 _group_name, address _groupie) public
    constant
    returns (bool _is_groupie)
    {
        _is_groupie = GroupsMap[_group_name][_groupie];
    }

    function isOwnerAddress(address _owner) public
    constant
    returns (bool _is_owner)
    {
        _is_owner = _owner == owner;
    }

    function isAdmin(address _account) public
    constant
    returns (bool _is_admin)
    {
        _is_admin = GroupsMap[ADMINS][_account];
    }
}
