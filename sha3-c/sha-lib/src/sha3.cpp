
#include <iostream>
#include <cstring>
#include <iomanip>
#include <cassert>

#include <sha3/sha3.h>
#include <sha3/keccak_p.h>

namespace sha3 {
    
    Hash::Hash(const char* value, size_t size, bool own) : _size(size), _value(value) {
        if(!own) {
            _value = new char[size];
            memcpy((void *) _value, value, size);
        }
    }
    
    Hash::Hash(Hash&& value) noexcept : _value(value._value), _size(value._size) {
        value._value = nullptr;
        value._size = 0;
    }
    
    Hash::~Hash() {
        delete[] _value;
    }
    
    const char* Hash::value() const {
        return _value;
    }
    
    size_t Hash::size() const {
        return _size;
    }

    size_t pad(char **result, const void* input, size_t length, size_t block_size)  {
        if(result == nullptr) {
            return 0;
        }
        size_t blockCount = (length + 1) / block_size;
        if((length + 1) % block_size != 0) {
            ++blockCount;
        }
        size_t padded_length = blockCount * block_size;
        auto* res = new unsigned char[padded_length];
        memcpy(res, input, length);
        unsigned char* pad_begin = res + length;
        size_t pad_length = padded_length - length;
        if(pad_length == 1) {
            *pad_begin = 0b10000110;
        } else {
            memset(pad_begin + 1, 0, pad_length - 2);
            *pad_begin = 0b00000110;
            pad_begin[pad_length - 1] = 0b10000000;
        }
        *result = (char*) res;
        return padded_length;
    }
    
    static Hash hash(const char* message, std::size_t length, std::size_t output_length) {
        assert(output_length <= 64);
        const size_t block_size = 200 - 2 * output_length;
        char* padded = nullptr;
        size_t padded_size = sha3::pad(&padded, message, length, block_size);
        size_t block_count = padded_size / block_size;
        assert(padded_size % block_size == 0);
        keccak::StateArray state;
        keccak::StateArray in;
        memset(&state, 0, 200);
        for(size_t i = 0; i < block_count; i++) {
            void* block = padded + block_size * i;
            memset(&in, 0, 200);
            memcpy(&in, block, block_size);
            for(uint8_t y = 0; y < 5; y++) {
                for (uint8_t x = 0; x < 5; x++) {
                    in[y][x] xor_eq state[y][x];
                }
            }
            keccak::keccak_f(state, in);
        }
        
        char* result = new char[output_length];
        if(output_length > 200) {
            throw std::runtime_error("Output length greater than 200 bytes is not supported");
        }
        memcpy(result, &state, output_length);
        delete padded;
        return Hash{result, output_length, true};
    }
    
    Hash sha3_224(const char* message, std::size_t length) {
        return hash(message, length, 24);
    }
    Hash sha3_256(const char* message, std::size_t length) {
        return hash(message, length, 32);
    }
    Hash sha3_384(const char* message, std::size_t length) {
        return hash(message, length, 48);
    }
    Hash sha3_512(const char* message, std::size_t length) {
        return hash(message, length, 64);
    }
    
}

std::ostream& operator <<(std::ostream& stream, const sha3::Hash& value) {
    stream << std::hex;
    for(int i = 0; i < value.size(); i++) {
        stream << std::setw(2) << std::setfill('0') << (int) (unsigned char) value.value()[i] << std::flush;
    }
    stream << std::dec << std::flush;
    return stream;
}
