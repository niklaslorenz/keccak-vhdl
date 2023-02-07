src_dir=$(pwd)/src
test_dir=$(pwd)/test

sources=( \
"state" \
"util" \
"visualizer" \
"round_constants" \
"functions" \
"modules/reader" \
"modules/writer" \
"modules/calculator" \
"modules/chunk_calculator" \
"modules/result_writer" \
"modules/slice_manager" \
"sha3_atom" \
)

test_instances=( \
"state_test" \
"theta_test" \
"calculator_test" \
"result_writer_test" \
"slice_manager_test" \
"atom_read_test" \
#"buffer_data_transmit_test" \
"atom_full_test" \
)

test_sources=("")
test_sources+=(${test_instances[@]})

echo export test instances
mkdir -p ../build/sha3-icore
echo ${test_instances[@]} > ../build/sha3-icore/test_instances

pushd . > /dev/null
cd ../build/sha3-icore
echo clear icore work directory
rm -r -f ./work

echo build icore sources
for f in ${sources[@]}; do
nvc -a "${src_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build source file ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

echo build vhdl test sources
for f in ${test_sources[@]}; do
nvc -a "${test_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build test file ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

echo elaborate vhdl test instances
for f in ${test_instances[@]}; do
nvc -e ${f}
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to elaborate test instance ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

popd > /dev/null
exit 0
