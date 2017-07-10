pragma solidity ^0.4.11;

import './AcGroups.sol';


// This contract is a slightly modified version of open-zeppelin lifecycle/Pausable.sol

/**
 * @title AcPause
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract AcPause is AcGroups {
    bytes32 private PAUSE_ADMINS;

    event Pause();
    event Resume();

    bool private paused = false;

    /**
     * @dev modifier to allow actions only when the contract is active
     */
    modifier whenActive()
    {
        assert(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract is paused
     */
    modifier whenPaused
    {
        assert(paused);
        _;
    }

    function AcPause()
    {
        PAUSE_ADMINS = const.PAUSE_ADMINS();
        GroupsMap[PAUSE_ADMINS][owner] = true;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public
    onlyGroupie(PAUSE_ADMINS) whenActive
    returns (bool _success)
    {
        paused = true;
        Pause();
        _success = true;
    }

    /**
     * @dev called by the owner to resume, returns to normal state
     */
    function resume() public
    onlyGroupie(PAUSE_ADMINS) whenPaused
    returns (bool _success)
    {
        paused = false;
        Resume();
        _success = true;
    }


    function isPaused() public
    constant
    returns (bool _is_paused)
    {
        _is_paused = paused;
    }
}
