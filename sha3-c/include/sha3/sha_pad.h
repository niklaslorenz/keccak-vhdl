//
// Created by lornik00 on 12.10.22.
//

#ifndef KECCAK_SHA_PAD_H
#define KECCAK_SHA_PAD_H

#include <string>
#include <cstring>
#include <cassert>

namespace sha3 {

    template<size_t block_length>
    size_t pad(char **result, const void* input, size_t length, bool zero_terminate = false) {
        static_assert(block_length % 8 == 0, "block length must be a multiple of 8");
        if(result == nullptr) {
            return 0;
        }
        const size_t block_size = block_length / 8;
        size_t blockCount = (length + 1) / block_size;
        if((length + 1) % block_size != 0) {
            ++blockCount;
        }
        size_t padded_length = blockCount * block_size;
        size_t res_length = padded_length + (zero_terminate ? 1 : 0);
        char* res = new char[res_length];
        memcpy(res, input, length);
        char* pad_begin = res + length;
        size_t pad_length = padded_length - length;
        if(pad_length == 1) {
            *pad_begin = 0b10000110;
        } else {
            *pad_begin = 0b00000110;
            for(int i = 1; i < pad_length - 1; i++) {
                pad_begin[i] = 0;
            }
            pad_begin[pad_length - 1] = 0b10000000;
        }
        if(zero_terminate) {
            res[pad_length] = 0;
        }
        *result = res;
        return res_length;
    }

    template<size_t block_length>
    size_t pad(char** result, const std::string& input) {
        return pad<block_length>(result, input.c_str(), input.length());
    }

}

#endif //KECCAK_SHA_PAD_H
