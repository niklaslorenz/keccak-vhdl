//
// Created by niklas on 10/24/22.
//

#include <sha3/util.h>
#include <stdexcept>
#include <sha3/sha3.h>

namespace sha3 {
    namespace util {


        char getHexChar(unsigned char number) {
            if (number < 10) {
                return (char) ('0' + number);
            }
            if (number < 16) {
                return (char) ('A' + number - 10);
            }
            throw std::runtime_error("Cannot convert to hex value");
        }

        char parseHexChar(char hex) {
            int temp = hex - '0';
            if (hex >= '0' && hex <= '9') {
                return (char) (hex - '0');
            }
            if (hex >= 'A' && hex <= 'F') {
                return (char) (hex - 'A' + 10);
            }
            if (hex >= 'a' && hex <= 'f') {
                return (char) (hex - 'a' + 10);
            }
            throw std::runtime_error("Unrecognisable hex character");
        }

        void parseStateArray(keccak::StateArray &result, const std::string &str) {
            size_t len = std::min(str.length(), 2 * sizeof(keccak::StateArray));
            std::string parsed = str;
            if (len % 2 != 0) {
                parsed.append("0");
            }
            char *res = (char *) (void *) &result;
            for (size_t i = 0; i < len / 2; i++) {
                res[i] = (char) ((parseHexChar(parsed.c_str()[2 * i]) << 4) |
                                 (parseHexChar(parsed.c_str()[2 * i + 1]) & 0b00001111));
            }
        }

        std::string parseStateArray(const keccak::StateArray &stateArray) {
            char str[401];
            str[400] = 0;
            auto state = (unsigned char *) (void *) &stateArray;
            for (int i = 0; i < 200; i++) {
                str[2 * i] = getHexChar((unsigned char) (state[i] >> 4));
                str[2 * i + 1] = getHexChar((unsigned char) (state[i] & 0b00001111));
            }
            return std::string{str};
        }

    }
}