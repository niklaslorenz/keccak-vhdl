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
#include <bitset>
#include <cstring>

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

const std::function<void(std::istream& input, std::ostream& output)> getReformatFunction(const std::string& name) {
    if(name == "array2slices") {
        return [](std::istream& input, std::ostream& output) {
            keccak::StateArray state;
            input >> state;
            
            for(int i = 0; i < 64; i++) {
                int tile_slice = 0;
                for(int j = 12; j >= 0; j--) {
                    int x = j % 5;
                    int y = j / 5;
                    tile_slice = (tile_slice << 1) | (state[y][x] >> i) & 1;
                }
                output << "slice " << std::dec << std::setw(2) << std::setfill('0') << i << ": " << std::flush
                << std::hex << std::setw(4) << std::setfill('0') << tile_slice << std::flush
                << " | " << std::bitset<13>(tile_slice) << std::endl;
            }
            output << std::endl;

            for(int i = 0; i < 64; i++) {
                int tile_slice = 0;
                for(int j = 24; j >= 12; j--) {
                    int x = j % 5;
                    int y = j / 5;
                    tile_slice = (tile_slice << 1) | (state[y][x] >> i) & 1;
                }
                output << "slice " << std::dec << std::setw(2) << std::setfill('0') << i << ": " << std::flush
                << std::hex << std::setw(4) << std::setfill('0') << tile_slice << std::flush
                << " | " << std::bitset<13>(tile_slice) << std::endl;
            }

            output << std::dec << std::flush;
        };
    }
    if(name == "pad2array") {
        return [](std::istream& input, std::ostream& output){
            keccak::StateArray state;
            memset(&state, 0, 200);
            std::string line;
            std::getline(input, line);

            if(line.length() != 1088 / 8 * 2) {
                std::cout << "Wrong input length" << std::endl;
                return;
            }

            size_t iterator = 0;
            for(int i = 0; i < 17; i++) {
                int x = i % 5;
                int y = i / 5;
                char* lane = (char*)(void*) &state[y][x];
                for(int j = 0; j < 8; j++) {
                    char dat = std::stoi(line.substr(iterator, 2), 0, 16);
                    iterator += 2;
                    lane[j] = dat;
                }
            }

            output << state << std::endl;
        };
    }
    if(name == "array2lanes") {
        return [](std::istream& input, std::ostream& output){
            keccak::StateArray state;
            input >> state;
            for(int y = 4; y >= 0; y--) {
                for(int x = 4; x >= 0; x--) {
                    output << "lane " << std::dec << std::setw(2) << std::setfill('0') << y * 5 + x << ": " << std::flush
                    << std::hex << std::setw(16) << std::setfill('0') << state[y][x] << std::endl << std::flush;
                }
            }
            output << std::dec;
        };
    }
    if(name == "array2binary") {
        return [](std::istream& input, std::ostream& output) {
            keccak::StateArray state;
            input >> state;
            for(int y = 4; y >= 0; y--) {
                for(int x = 4; x >= 0; x--) {
                    output << "lane " << std::dec << std::setw(2) << std::setfill('0') << y * 5 + x << ": "
                    << std::hex << std::setw(16) << std::setfill('0') << state[y][x] << " | " << std::flush
                    << std::flush << std::bitset<64>(state[y][x]) << std::endl;
                }
            }
            output << std::dec;
        };
    }
    return nullptr;
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
    if(name == "gamma") return keccak::gamma;
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

    auto reformatFunction = getReformatFunction(name);
    if(reformatFunction != nullptr) {
        return [reformatFunction, name](int argc, const char** argv, std::istream& input, std::ostream& output) {
            if(argc != 0) {
                std::cout << "expected no function parameter for function " << name << std::endl;
            }
            reformatFunction(input, output);
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

    std::ostream* outputStream;
    std::ofstream outputFile;
    if(strcmp(argv[argc - 1], "out") == 0) {
        outputStream = &std::cout;
    } else {
        outputFile.open(argv[argc - 1]);
        outputStream = &outputFile;
    }

    return function(argc - 4, argv + 2, inputFile, *outputStream);

}
