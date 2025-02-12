// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title JiblycoinLibraries
 * @notice Provides utility functions for converting numbers and addresses to strings.
 * @dev Contains helper functions that are widely used across the Jiblycoin ecosystem.
 */
library JiblycoinLibraries {
    /**
     * @notice Converts a uint256 value to its ASCII string decimal representation.
     * @param value The uint256 value to convert.
     * @return The string representation of the number.
     */
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

    /**
     * @notice Compares two strings for equality.
     * @param a The first string.
     * @param b The second string.
     * @return True if the strings are equal, false otherwise.
     */
    function stringsEqual(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }

    /**
     * @notice Converts an Ethereum address to its ASCII string hexadecimal representation.
     * @param account The address to convert.
     * @return The string hexadecimal representation of the address.
     */
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
