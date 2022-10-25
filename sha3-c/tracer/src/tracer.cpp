//
// Created by niklas on 10/24/22.
//

#include <iostream>
#include <fstream>
#include <sha3/keccak_p.h>
#include <sstream>
#include <functional>

void execute(const std::function<void(keccak::StateArray&, const keccak::StateArray&)>& f, std::istream& input, std::ostream& output) {
    keccak::StateArray state;
    keccak::StateArray result;
    while(!input.eof()) {
        input >> state;
        f(result, state);
        output << result << std::endl;
    }
}

int iota(int argc, const char** argv, std::istream& input, std::ostream& output) {
    if(argc != 1) {
        std::cout << "Expected one function parameter: <round index>" << std::endl;
        return 1;
    }
    int roundIndex;
    std::stringstream arg(argv[0]);
    arg >> roundIndex;
    if(roundIndex < 0 || roundIndex > 23) {
        std::cout << "The round index must be between 0 and 23" << std::endl;
        return 1;
    }
    execute([roundIndex](keccak::StateArray& res, const keccak::StateArray& input) {keccak::iota(res, input, roundIndex);}, input, output);
    return 0;
}

std::function<void(keccak::StateArray&, const keccak::StateArray&)> getPermutationFunction(const std::string& name) {
    if(name == "theta") return keccak::theta;
    if(name == "rho") return keccak::rho;
    if(name == "pi") return keccak::pi;
    if(name == "chi") return keccak::chi;
    return nullptr;
}

std::function<int(int argc, const char** argv, std::istream&, std::ostream&)> getFunctionForName(const std::string& name) {
    if(name == "iota") return iota;

    auto permutation = getPermutationFunction(name);
    if(permutation != nullptr) {
        return [permutation, name](int argc, const char** argv, std::istream& input, std::ostream& output) {
            if(argc != 0) {
                std::cout << "expected no function parameters for function " << name << std::endl;
                return 1;
            }
            execute(permutation, input, output);
            return 0;
        };
    }

    return nullptr;
}

int main(int argc, const char** argv) {

    const std::string syntax = "Usage: tracer <function> <function parameters> <input file> <output file>";

    if(argc < 4) {
        std::cout << syntax << std::endl;
    }

    std::string functionName = argv[1];

    auto function = getFunctionForName(functionName);
    if(function == nullptr) {
        std::cout << "Unknown function: " << functionName << std::endl;
        return 1;
    }

    std::ifstream inputFile;
    inputFile.open(argv[argc - 2]);
    std::ofstream outputFile;
    outputFile.open(argv[argc - 1]);

    return function(argc - 4, argv + 2, inputFile, outputFile);

}
