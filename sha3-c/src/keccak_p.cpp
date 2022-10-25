
#include "sha3/keccak_p.h"
#include <cassert>
#include <iostream>
#include <bitset>

namespace keccak {

    static const std::array<std::array<uint16_t, 5>, 5> rho_shifts {
            0, 1, 62, 28, 27,
            36, 44, 6, 55, 20,
            3, 10, 43, 25, 39,
            41, 45, 15, 21, 8,
            18, 2, 61, 56, 14
    };

    static const std::array<Lane, 24> roundConstants {
            1ULL,
            32898ULL,
            9223372036854808714ULL,
            9223372039002292224ULL,
            32907ULL,
            2147483649ULL,
            9223372039002292353ULL,
            9223372036854808585ULL,
            138ULL,
            136ULL,
            2147516425ULL,
            2147483658ULL,
            2147516555ULL,
            9223372036854775947ULL,
            9223372036854808713ULL,
            9223372036854808579ULL,
            9223372036854808578ULL,
            9223372036854775936ULL,
            32778ULL,
            9223372039002259466ULL,
            9223372039002292353ULL,
            9223372036854808704ULL,
            2147483649ULL,
            9223372039002292232ULL
    };

    void theta(StateArray& result, const StateArray& input) {
        assert(&result != &input);
        for(uint8_t x = 0; x < 5; x++) {
            Lane pairity = 0;
            for(uint8_t y = 0; y < 5; y++) {
                Lane temp = input[y][(x + 1) % 5];
                pairity xor_eq input[y][(x + 4) % 5] xor ((temp << 1) | (temp >> 63));
            }
            for(uint8_t y = 0; y < 5; y++) {
                result[y][x] = input[y][x] xor pairity;
            }
        }
    }

    void rho(StateArray& result, const StateArray& input) {
        assert(&result != &input);
        result[0][0] = input[0][0];
        for(uint8_t y = 0; y < 5; y++) {
            for(uint8_t x = 0; x < 5; x++) {
                result[y][x] = rotl(input[y][x], rho_shifts[y][x]);
            }
        }
    }

    void pi(StateArray& result, const StateArray& input) {
        assert(&result != &input);
        for(uint8_t y = 0; y < 5; y++) {
            for(uint8_t x = 0; x < 5; x++) {
                result[y][x] = input[x][(x + 3 * y) % 5];
            }
        }
    }

    void chi(StateArray& result, const StateArray& input) {
        assert(&result != &input);
        for(uint8_t y = 0; y < 5; y++) {
            for(uint8_t x = 0; x < 5; x++) {
                result[y][x] = input[y][x] xor ((~input[y][(x + 1) % 5]) & input[y][(x + 2) % 5]);
            }
        }
    }

    void iota(StateArray& result, const StateArray& input, uint8_t roundIndex) {
        if(&result != &input) {
            result = input;
        }
        result[0][0] xor_eq roundConstants[roundIndex];
    }

    void keccak_p(StateArray& result, const StateArray& input, uint8_t roundIndex) {
        StateArray temp1 = input, temp2;
        theta(temp2, temp1);
        rho(temp1, temp2);
        pi(temp2, temp1);
        chi(temp1, temp2);
        iota(result, temp1, roundIndex);
    }

    void keccak_f(StateArray& result, const StateArray& input) {
        StateArray temp1 = input, temp2;
        for(uint8_t i = 0; i < 24; i++) {
            theta(temp2, temp1);
            rho(temp1, temp2);
            pi(temp2, temp1);
            chi(temp1, temp2);
            iota(temp1, temp1, i);
        }
        result = temp1;
    }

}