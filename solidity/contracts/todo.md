### TODO
* Use revert or return success bool instead of assert and require. This will prevent using up of all gas when the contract isn't in security danger. 
* Use types smaller than uint256 where applicable to save storage.
* Use int instead of uint where applicable.
* Remove safe math where not needed