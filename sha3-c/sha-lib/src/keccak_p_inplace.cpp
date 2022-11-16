
#include <sha3/keccak_p.h>
#include <string>
#include <iomanip>
#include <cstring>

namespace keccak {

	inline void theta_ip(StateArray& s) {
		Lane pairities[5];
		for (uint8_t x = 0; x < 5; x++) {
			pairities[x] = s[0][x] xor s[1][x] xor s[2][x] xor s[3][x] xor s[4][x];
		}
		Lane combinedPairities[5];
		for (uint8_t x = 0; x < 5; x++) {
			combinedPairities[x] = pairities[(x + 4) % 5] xor rotl(pairities[(x + 1) % 5], 1);
		}
		for (uint8_t y = 0; y < 5; y++) {
			for (uint8_t x = 0; x < 5; x++) {
				s[y][x] xor_eq combinedPairities[x];
			}
		}
	}

	inline void pichi_ip(StateArray& s) {
		
	}

	//Gamma = theta . iota . chi . pi
	void gamma_ip(StateArray& s, uint8_t roundIndex) {
		assert(roundIndex < 25);
		pichi_ip(s);
		s[0][0] xor_eq roundConstants[roundIndex];
		theta_ip(s);
	}
	
}
