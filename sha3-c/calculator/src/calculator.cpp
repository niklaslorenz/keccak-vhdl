
#include <cstring>
#include <iostream>
#include <fstream>
#include <sha3/keccak_p.h>

enum Function {
    sha224,
    sha256,
    sha384,
    sha512,
    theta,
    rho,
    pi,
    chi,
    iota,
    nop
};

Function getFunction(const char* arg) {
    if(strcmp(arg, "sha224") == 0) return sha224;
    if(strcmp(arg, "sha256") == 0) return sha256;
    if(strcmp(arg, "sha384") == 0) return sha384;
    if(strcmp(arg, "sha512") == 0) return sha512;
    if(strcmp(arg, "theta") == 0) return theta;
    if(strcmp(arg, "rho") == 0) return rho;
    if(strcmp(arg, "pi") == 0) return pi;
    if(strcmp(arg, "chi") == 0) return chi;
    if(strcmp(arg, "iota") == 0) return iota;
    return nop;
}

void simpleIota(keccak::StateArray& result, const keccak::StateArray& input) {
    keccak::iota(result, input, 0);
}

void (*getPermutation(Function f))(keccak::StateArray&, const keccak::StateArray&) {
    switch(f) {
        case theta: return keccak::theta;
        case rho: return keccak::rho;
        case pi: return keccak::pi;
        case chi: return keccak::chi;
        case iota: return simpleIota;
        default: return nullptr;
    }
}

void calculateHashes(Function f, std::ifstream& input) {

}

inline char parseHexChar(char hex) {
    int temp = hex - '0';
    if(hex >= '0' && hex <= '9') {
        return (char) (hex - '0');
    }
    if(hex >= 'A' && hex <= 'F') {
        return (char) (hex - 'A' + 10);
    }
    if(hex >= 'a' && hex <= 'f') {
        return (char) (hex - 'a' + 10);
    }
    throw std::runtime_error("Unrecognisable hex character");
}

inline char getHexChar(unsigned char number) {
    if(number < 10) {
        return (char)('0' + number);
    }
    if(number < 16) {
        return (char)('A' + number - 10);
    }
    throw std::runtime_error("Cannot convert to hex value");
}

void parseStateArray(keccak::StateArray& result, const std::string& str) {
    size_t len = std::min(str.length(), 2 * sizeof(keccak::StateArray));
    std::string parsed = str;
    if(len % 2 != 0) {
        parsed.append("0");
    }
    char* res = (char*)(void*)&result;
    for(size_t i = 0; i < len / 2; i++) {
        res[i] = (char) ((parseHexChar(parsed.c_str()[2 * i]) << 4) | (parseHexChar(parsed.c_str()[2 * i + 1]) & 0b00001111));
    }
}

std::string parseStateArray(const keccak::StateArray& stateArray) {
    char str[401];
    str[400] = 0;
    auto state = (unsigned char*)(void*)&stateArray;
    for(int i = 0; i < 200; i++) {
        str[2 * i] = getHexChar((unsigned char)(state[i] >> 4));
        str[2 * i + 1] = getHexChar((unsigned char)(state[i] & 0b00001111));
    }
    return std::string{str};
}

void calculatePermutations(Function f, std::ifstream& input, std::ofstream& output) {
    std::string line;
    auto permutation = getPermutation(f);
    keccak::StateArray in, out;
    while(std::getline(input, line)) {
        parseStateArray(in, line);
        permutation(out, in);
        output << parseStateArray(out) << std::endl;
    }
}

int main(int argc, const char** argv) {

    if(argc != 4) {
        std::cerr << "Expected three arguments <function, input file, output file> but got " << argc - 1 << std::endl;
        return 1;
    }

    Function f = getFunction(argv[1]);
    std::ifstream inputFile;
    inputFile.open(argv[2]);
    std::ofstream outputFile;
    outputFile.open(argv[3]);

    int ret;

    switch(f) {
        case sha224:
        case sha256:
        case sha384:
        case sha512:
            calculateHashes(f, inputFile);
            ret = 0;
            break;
        case theta:
        case rho:
        case pi:
        case chi:
        case iota:
            calculatePermutations(f, inputFile, outputFile);
            ret = 0;
            break;
        default:
            std::cerr << "Unrecognised Function: " << argv[1] << std::endl;
            ret = 1;
            break;
    }
    inputFile.close();
    outputFile.close();
    return ret;

}