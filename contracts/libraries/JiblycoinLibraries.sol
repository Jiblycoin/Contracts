// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library JiblycoinLibraries {
    error ZeroAddress();
    error InsufficientBalance();

    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function stringsEqual(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }

    function addressToString(address account) internal pure returns (string memory) {
        bytes memory data = abi.encodePacked(account);
        bytes memory hexChars = "0123456789abcdef";
        bytes memory buffer = new bytes(2 + data.length * 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            buffer[2 + i * 2] = hexChars[uint8(data[i] >> 4)];
            buffer[3 + i * 2] = hexChars[uint8(data[i] & 0x0f)];
        }
        return string(buffer);
    }
}
