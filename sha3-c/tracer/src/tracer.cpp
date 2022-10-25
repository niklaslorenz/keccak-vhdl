//
// Created by niklas on 10/24/22.
//

#include <iostream>
#include <fstream>
#include <sha3/keccak_p.h>

int main(int argc, const char** argv) {

    if(argc != 3) {
        std::cerr << "Expected two parameters: input file and output file" << std::endl;
    }

    std::ifstream inputFile;
    inputFile.open(argv[1]);
    std::ofstream outputFile;
    outputFile.open(argv[2]);
    std::string line;
    std::getline(inputFile, line);
    keccak::StateArray array, temp;
    sha3::util::parseStateArray(array, line);
    outputFile << sha3::util::parseStateArray(array) << std::endl;
    for(int i = 0; i < 24; i++) {
        temp = array;
        keccak::keccak_p(array, temp, i);
        outputFile << sha3::util::parseStateArray(array) << std::endl;
    }

}