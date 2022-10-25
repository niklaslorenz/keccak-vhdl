
#include <cstring>
#include <iostream>
#include <fstream>
#include <sha3/sha3.h>

sha3::Hash (*getHashFunction(const char* name))(const char *, size_t) {
    if(strcmp(name, "sha3-224") == 0) return sha3::sha3_224;
    if(strcmp(name, "sha3-256") == 0) return sha3::sha3_256;
    if(strcmp(name, "sha3-384") == 0) return sha3::sha3_384;
    if(strcmp(name, "sha3-512") == 0) return sha3::sha3_512;
    return nullptr;
}

void calculate(std::istream& in, std::ostream& out, sha3::Hash (*function)(const char*, size_t)) {
    std::string input_line;
    while(getline(in, input_line)) {
        if(strcmp(input_line.c_str(), "quit") == 0) {
            break;
        }
        sha3::Hash hash = function(input_line.c_str(), input_line.size());
        out << hash << std::endl;
    }
}

int main(int argc, const char** argv) {
    const std::string syntax = "calculator <function> [<input file> <output file>]\nFunctions are expressed as \"sha3-<n>\" with <n> being the hash length\nExample: sha3-256";
    if(argc != 4 && argc != 2) {
        std::cout << "Usage: " << syntax << std::endl;
        return 1;
    }

    auto function = getHashFunction(argv[1]);
    if(function == nullptr) {
        std::cout << "unknown function: " << argv[1] << std::endl;
        return 1;
    }

    if(argc == 2) {
        calculate(std::cin, std::cout, function);
    } else {
        std::ifstream inputFile;
        inputFile.open(argv[2]);
        std::ofstream outputFile;
        outputFile.open(argv[3]);
        calculate(inputFile, outputFile, function);
    }

    return 0;

}
