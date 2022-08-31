// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";

contract ForTheDog is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant LOCK_TRANSFER_ROLE = keccak256("LOCK_TRANSFER_ROLE");

    uint256 private _limitMint;

    mapping(address => bool) internal _FullLockList;

    constructor() ERC20("ForTheDog", "FTD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 1600000000 * 10 ** decimals());
        _limitMint = 1600000000 * 10 ** decimals();
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(LOCK_TRANSFER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= _limitMint, "The number of additional issuance has been exceeded.");
        _mint(to, amount);
    }

    function recoveryTokenTransfer(address from , address to , uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
        super._transfer(from , to , amount);
    }

    function FullLockAddress(address account) external onlyRole(LOCK_TRANSFER_ROLE) returns (bool) {
        _FullLockList[account] = true;
        return true;
    }

    function unFullLockAddress(address account) external onlyRole(LOCK_TRANSFER_ROLE) returns (bool) {
        delete _FullLockList[account];
        return true;
    }

    function FullLockedAddressList(address account) external view virtual returns (bool) {
        return _FullLockList[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        require(!_FullLockList[from], "Token transfer from LockedAddressList");
        super._beforeTokenTransfer(from, to, amount);
    }
}