# sha3-vhdl
Goal of this project is to provide vhdl and c++ implementations for the SHA-3 hash functions

## Project Status
|Component|Status|
|-|-|
|sha3-c|working|
|sha3-vhdl|working|
|sha3-icore|development|

### The Calculator
The calculator application in the sha3-c module can generate hashes for every SHA-3 function either in an
iteractive mode or by providing it with an input file. It then will generate the hash of every line in
that file and write it to the output file.

## Build Requirements
In addition to all the neccessary tools for c development, this project
uses the nvc vhdl simulator. You can get it [here](https://github.com/nickg/nvc).

## How To Build
Make sure you meet all the [build requirements](#Build-Requirements).
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
