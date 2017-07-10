pragma solidity ^0.4.11;

import '../stores/ConstantsStore.sol';

contract HasConstants {
    ConstantsStore public const;

    function HasConstants(address _constants) {
        require(_constants != address(0));
        const = ConstantsStore(_constants);
    }
}