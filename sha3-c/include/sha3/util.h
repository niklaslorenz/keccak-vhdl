//
// Created by niklas on 10/24/22.
//

#ifndef KECCAK_UTIL_H
#define KECCAK_UTIL_H

#include <sha3/sha3.h>

namespace sha3 {
    namespace util {

        char getHexChar(unsigned char number);

        char parseHexChar(char hex);

        void parseStateArray(keccak::StateArray& result, const std::string& str);

        std::string parseStateArray(const keccak::StateArray& stateArray);
    }
}

#endif //KECCAK_UTIL_H
