//
// Created by lornik00 on 10.10.22.
//

#ifndef KECCAK_SHA_3_H
#define KECCAK_SHA_3_H

#include <sha3/sha_pad.h>
#include <sha3/keccak_p.h>
#include <cassert>
#include <array>

namespace sha3 {

    template<typename returnType, size_t output_length>
    returnType sha3(const char* message, std::size_t length) {
        const size_t c = 2 * output_length;
        const size_t r = 1600 - c;
        const size_t blockSize = r / 8;
        static_assert(blockSize % 8 == 0, "block size must be a multiple of 8");
        char* padded = nullptr;
        size_t padded_size = sha3::pad<r>(&padded, message, length, false);
        size_t block_count = (padded_size * 8) / r;
        assert((padded_size * 8) % r == 0);
        keccak::StateArray state;
        keccak::StateArray in;
        memset(&state, 0, 200);
        for(size_t i = 0; i < block_count; i++) {
            void* block = padded + 200 * i;
            memset(&in, 0, 200);
            memcpy(&in, block, blockSize);
            for(uint8_t y = 0; y < 5; y++) {
                for (uint8_t x = 0; x < 5; x++) {
                    in[y][x] xor_eq state[y][x];
                }
            }
            keccak::keccak_f(state, in);
        }

        size_t res_size = 0;
        returnType result;
        void* res_location = &result;
        while(res_size < output_length / 8) {
            size_t iteration_size = std::min(output_length / 8 - res_size, r / 8);
            memcpy(res_location, &state, iteration_size);
            res_size += r / 8;
            res_location = ((char*) res_location) + r / 8;
        }
        delete padded;
        return result;
    }

    const auto sha3_224 = sha3<std::array<uint32_t, 7>, 224>;
    const auto sha3_256 = sha3<std::array<uint64_t, 4>, 256>;
    const auto sha3_384 = sha3<std::array<uint64_t, 6>, 384>;
    const auto sha3_512 = sha3<std::array<uint64_t, 8>, 512>;

}

#endif //KECCAK_SHA_3_H
