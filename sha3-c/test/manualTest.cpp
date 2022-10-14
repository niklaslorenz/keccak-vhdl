
#include <sha3/sha3.h>
#include <iostream>

int main() {
    std::string str = "HelloWorld!";
    while(str != "quit") {
        std::cin >> str;
        auto result = sha3::sha3_256(str.c_str(), str.size());
        std::cout << std::hex;
        for(int i = 0; i < 4; i++) {
            uint64_t x = result[i];
            x = x << 32 | x >> 32;
            x = ((x << 16) & 0xFFFF0000FFFF0000) | ((x >> 16) & 0x0000FFFF0000FFFF);
            x = ((x << 8) & 0xFF00FF00FF00FF00) | ((x >> 8) & 0x00FF00FF00FF00FF);
            std::cout << std::setw(16) << std::setfill('0') << x;
            std::cout.flush();
        }
        std::cout << std::dec << std::endl;
    }
}