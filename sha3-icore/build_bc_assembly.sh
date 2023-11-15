#START OF CONFIGURATION BLOCK
#EDIT PROJECT SOURCES HERE

#number of bc assembly steps (be careful to include step 0 ;) )
bc_assembly_steps=18

#END OF CONFIGURATION BLOCK
#LEAVE THE REST AS IS

bc_assembly_dir=$(pwd)/bc_assembly

pushd . > /dev/null
cd ../build/sha3-icore

echo build bc assembly file
mkdir -p ./bc_assembly
rm -f ./bc_assembly/sha3.bc
touch ./bc_assembly/sha3.bc
for (( c=0; c<${bc_assembly_steps}; c++))
do
cat ${bc_assembly_dir}/step_${c}.bc >> ./bc_assembly/sha3.bc
if [ $? -ne 0 ]; then
exit 1
fi
done
if [ $? -ne 0 ]; then
exit 1
fi

popd > /dev/null
exit 0
