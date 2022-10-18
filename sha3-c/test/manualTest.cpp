
#include <sha3/sha3.h>
#include <iostream>
#include <iomanip>

void print(std::array<uint64_t, 4>& result) {
    std::cout << std::hex;
    for(int i = 0; i < sizeof(result) / sizeof(uint64_t); i++) {
        uint64_t x = result[i];
        x = x << 32 | x >> 32;
        x = ((x << 16) & 0xFFFF0000FFFF0000) | ((x >> 16) & 0x0000FFFF0000FFFF);
        x = ((x << 8) & 0xFF00FF00FF00FF00) | ((x >> 8) & 0x00FF00FF00FF00FF);
        std::cout << std::setw(16) << std::setfill('0') << x;
        std::cout.flush();
    }
    std::cout << std::dec << std::endl;
}

int main(int argc, const char** argv) {
    if(argc > 2) {
        std::cerr << "Expected zero or one arguments but got " << argc - 1 << std::endl;
        return 1;
    }
    if(argc == 2) {
        auto result = sha3::sha3_256(argv[1], strlen(argv[1]));
        print(result);
        return 0;
    }
    std::string str;
    while(true) {
        std::getline(std::cin, str);
        if(str == "quit") {
            break;
        }
        auto result = sha3::sha3_256(str.c_str(), str.size());
        print(result);
    }
    return 0;
}