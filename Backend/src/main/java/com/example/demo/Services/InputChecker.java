package com.example.demo.Services;

import org.springframework.stereotype.Service;

@Service
public class InputChecker {
    public boolean containsInvalidHttpChars(String input) {
        // Regular expression to match invalid characters (non-ASCII, control chars, and DEL)
        String invalidCharsRegex = "[\\x00-\\x1F\\x7F\\x80-\\xFF]";

        // Check if the string contains any of the invalid characters
        return input.matches(".*" + invalidCharsRegex + ".*");
    }
}
