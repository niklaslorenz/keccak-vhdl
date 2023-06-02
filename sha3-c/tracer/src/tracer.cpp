//
// Created by niklas on 10/24/22.
//

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sha3/keccak_p.h>
#include <sha3/sha3.h>
#include <sstream>
#include <functional>

void execute(const std::function<void(keccak::StateArray&, const keccak::StateArray&)>& f, std::istream& input, std::ostream& output) {
    keccak::StateArray state;
    keccak::StateArray result;
    while(!input.eof()) {
        try {
            input >> state;
        } catch(keccak::end_of_input&) {
            break;
        }
        f(result, state);
        output << result << std::endl;
    }
}

const std::function<void(std::istream& input, std::ostream& output)> getPadFunction(const std::string& name) {
    size_t block_size = 0;
    if(name == "pad224") block_size = 1152 / 8;
    if(name == "pad256") block_size = 1088 / 8;
    if(name == "pad384") block_size = 832 / 8;
    if(name == "pad512") block_size = 576 / 8;
    if(block_size == 0) {
        return nullptr;
    }
    return [block_size](std::istream& input, std::ostream& output){
        std::string line;
        while(std::getline(input, line)) {
            char* result = nullptr;
            size_t output_size = sha3::pad(&result, line.c_str(), line.length(), block_size);
            output << std::hex;
            for(int i = 0; i < output_size; i++) {
                output << std::setw(2) << std::setfill('0') << (int) (unsigned char) result[i] << std::flush;
            }
            output << std::dec << std::endl;
            delete result;
        }
    };
}

std::function<void(keccak::StateArray&, const keccak::StateArray&, uint8_t)> getRoundDependentFunction(const std::string& name) {
    if(name == "iota") return keccak::iota;
    if(name == "keccak-p") return keccak::keccak_p;
    return nullptr;
}

std::function<void(keccak::StateArray&, const keccak::StateArray&)> getRoundIndependentFunction(const std::string& name) {
    if(name == "theta") return keccak::theta;
    if(name == "rho") return keccak::rho;
    if(name == "pi") return keccak::pi;
    if(name == "chi") return keccak::chi;
    if(name == "keccak-f") return keccak::keccak_f;
    return nullptr;
}

std::function<int(int argc, const char** argv, std::istream&, std::ostream&)> getFunctionForName(const std::string& name) {
    auto roundDependentFunction = getRoundDependentFunction(name);
    if(roundDependentFunction != nullptr) {
        return [roundDependentFunction, name](int argc, const char** argv, std::istream& input, std::ostream& output){
            if(argc != 1) {
                std::cout << "Expected one function parameter for function " << name << ": <round index>" << std::endl;
                return 1;
            }
            int roundIndex;
            std::stringstream arg(argv[0]);
            arg >> roundIndex;
            if(roundIndex < 0 || roundIndex > 23) {
                std::cout << "The round index must be between 0 and 23" << std::endl;
                return 1;
            }
            execute([roundIndex, roundDependentFunction](keccak::StateArray& res, const keccak::StateArray& input) {roundDependentFunction(res, input, roundIndex);}, input, output);
            return 0;
        };
    }

    auto roundIndependentFunction = getRoundIndependentFunction(name);
    if(roundIndependentFunction != nullptr) {
        return [roundIndependentFunction, name](int argc, const char** argv, std::istream& input, std::ostream& output) {
            if(argc != 0) {
                std::cout << "expected no function parameters for function " << name << std::endl;
                return 1;
            }
            execute(roundIndependentFunction, input, output);
            return 0;
        };
    }

    auto padFunction = getPadFunction(name);
    if(padFunction != nullptr) {
        return [padFunction, name](int argc, const char** argv, std::istream& input, std::ostream& output) {
            if(argc != 0) {
                std::cout << "expected no function parameter for function " << name << std::endl;
            }
            padFunction(input, output);
            return 0;
        };
    }

    return nullptr;
}

int main(int argc, const char** argv) {

    const std::string syntax = "Usage: tracer <function> [function parameters] <input file> <output file>";

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
