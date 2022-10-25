
#ifndef KECCAK_KECCAK_P_H
#define KECCAK_KECCAK_P_H

#include <cinttypes>
#include <stdexcept>
#include <array>

namespace keccak {

    typedef uint64_t Lane;
    typedef std::array<std::array<Lane, 5>, 5> StateArray;

    inline constexpr Lane rotl(Lane lane, uint16_t amount) {
        amount %= 64;
        return lane << amount | lane >> (64 - amount);
    }

    void theta(StateArray& result, const StateArray& input);

    void rho(StateArray& result, const StateArray& input);

    void pi(StateArray& result, const StateArray& input);

    void chi(StateArray& result, const StateArray& input);

    void iota(StateArray& result, const StateArray& input, uint8_t roundIndex);

    void keccak_p(StateArray& result, const StateArray& input, uint8_t roundIndex);

    void keccak_f(StateArray& result, const StateArray& input);

}

#endif //KECCAK_KECCAK_P_H
