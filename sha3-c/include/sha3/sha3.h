//
// Created by lornik00 on 10.10.22.
//

#ifndef KECCAK_SHA_3_H
#define KECCAK_SHA_3_H

#include <cinttypes>
#include <cstddef>
#include <iostream>

namespace sha3 {

    class Hash {
        const char* _value;
        size_t _size;
    public:
        Hash(const char* value, size_t size, bool own = false);
        Hash(Hash&&) noexcept ;
        virtual ~Hash();
        size_t size() const;
        const char* value() const;
    };

    size_t pad(char **result, const void* input, size_t length, size_t block_size);

    Hash sha3_224(const char* message, std::size_t length);
    Hash sha3_256(const char* message, std::size_t length);
    Hash sha3_384(const char* message, std::size_t length);
    Hash sha3_512(const char* message, std::size_t length);

}

std::ostream& operator << (std::ostream& stream, const sha3::Hash& value);

#endif //KECCAK_SHA_3_H
