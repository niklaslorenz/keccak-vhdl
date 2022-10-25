
#include <cstring>
#include <iostream>
#include <fstream>
#include <sha3/keccak_p.h>
#include <sha3/sha3.h>
#include <sha3/util.h>

using namespace sha3::util;

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
    keccak_p,
    keccak_f,
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
    if(strcmp(arg, "keccak-p") == 0) return keccak_p;
    if(strcmp(arg, "keccak-f") == 0) return keccak_f;
    return nop;
}

void simpleKeccak_p(keccak::StateArray& result, const keccak::StateArray& input) {
    keccak::StateArray temp1 = input, temp2;
    keccak::theta(temp2, temp1);
    keccak::rho(temp1, temp2);
    keccak::pi(temp2, temp1);
    keccak::chi(temp1, temp2);
    keccak::iota(result, temp1, 0);
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
        case keccak_p: return simpleKeccak_p;
        case keccak_f: return keccak::keccak_f;
        default: return nullptr;
    }
}

void calculateHashes(Function f, std::ifstream& input) {

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
        case keccak_p:
        case keccak_f:
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
