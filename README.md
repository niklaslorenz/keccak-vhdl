# keccak-vhdl
Goal of this project is to provide vhdl and c++ implementations for the SHA-3 hash functions

## Project Status
Currently we have a calculator application written in c++ as well as some rudimentary
implementations of the keccak functions in vhdl.
See [How to use](#HowToUse) for an introduction into the applications.
### The Calculator
The calculator application tcan generate hashes for every SHA-3 function
as well as transform the KECCAK-State-Arrays with the five different functions used in SHA-3.
The main usage for the calculator is to automatically generate test solutions for vhdl tests.
### VHDL Functions
SHA-3 uses a round function (keccak-f) that repeats a so called permutation function (keccak-p) 24 times.
keccak-p is a concatenation of five different functions: theta, rho, pi, chi and iota.
|Function|Description|Status|
|-|-|-|
|theta|Adds the sum of 10 other bits onto every bit of the state array|working|
|rho|Shifts every lane in the state array by a different amount|working|
|pi|Permutes the lanes of the state array|working|
|chi|Non linear function|working|
|iota|Adds the round constant onto the first lane|not working|
|keccak-p|Concatenation of the previous functions|not yet implemented|
|keccak-f|Repeats keccak-p 24 times with different round constants|not implemented yet|

## Build Requirements
This project uses the nvc vhdl simulator. You can get it [here](https://github.com/nickg/nvc)

## How To Build
Make sure you meet all the [build requirements](#BuildRequirements).
First clone the repository. Inside the repository execute the following commands:
- `./configure.sh` to setup the cmake project
- `./build.sh` to build the entire project
- `./test.sh` to run the vhdl tests

## How To Use
After you built the project, you will find the calculator executable inside the `./build/sha3-c/Debug/calculator` diretory.
Its syntax is as follows: `calculator <function name> <input file> <output file>`
|Parameter|Description|Value|
|-|-|-|
|Function Name|Name of the function that should be calculated|`sha224`, `sha256`, `sha384`, `sha512`, `theta`, `rho`, `pi`, `chi`, `iota`|
|Input File|For every line the specified function is evaluated. The sha functions take strings, the other functins take state arrays in hex representation|Path to the input file|
|Output File|Will contain every calculated value in a new line|Path to the output file|
