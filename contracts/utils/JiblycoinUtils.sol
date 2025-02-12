// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title JiblycoinUtils
 * @notice Provides utility functions for the Jiblycoin ecosystem.
 * @dev Includes conversion functions, safe arithmetic operations, and address conversion to string.
 */
library JiblycoinUtils {
    /**
     * @notice Converts a uint256 value to its ASCII string decimal representation.
     * @param value The uint256 value to convert.
     * @return The string representation of the value.
     */
    function toString(uint256 value) internal pure returns (string memory) {
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
     * @notice Safely adds two unsigned integers, reverting on overflow.
     * @param a The first operand.
     * @param b The second operand.
     * @return The sum of a and b.
     */
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert("AdditionOverflow");
        return c;
    }

    /**
     * @notice Safely subtracts one unsigned integer from another, reverting on underflow.
     * @param a The number to subtract from.
     * @param b The number to subtract.
     * @return The difference of a and b.
     */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) revert("SubtractionUnderflow");
        return a - b;
    }

    /**
     * @notice Safely multiplies two unsigned integers, reverting on overflow.
     * @param a The first operand.
     * @param b The second operand.
     * @return The product of a and b.
     */
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        if (c / a != b) revert("MultiplicationOverflow");
        return c;
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
