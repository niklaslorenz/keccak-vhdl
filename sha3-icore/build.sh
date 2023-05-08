src_dir=$(pwd)/src
test_dir=$(pwd)/test

sources=( \
"state" \
"util" \
"visualizer" \
"buffer_visualizer" \
"round_constants" \
"functions" \
"simulation/slice_memory_wrapper" \
"modules/memory_block" \
"modules/manual_port_memory_block" \
"modules/rho_buffer/single_lane_buffer" \
"modules/rho_buffer/multi_lane_buffer" \
"modules/rho_buffer/rho_buffer_filter" \
"modules/rho_buffer/rho_controller" \
"modules/rho_buffer/rho_buffer" \
"modules/gamma_calculator/single_slice_calculator" \
"modules/gamma_calculator/double_slice_calculator" \
"modules/gamma_calculator/clocked_double_slice_calculator" \
"modules/gamma_calculator/calculator_transmission_converter" \
"modules/gamma_calculator/calculator_data_combiner" \
"modules/gamma_calculator/calculator_controller" \
"modules/gamma_calculator/calculator" \
#"modules/reader" \
#"modules/writer" \
#"modules/slice_manager" \
#"sha3_atom" \
)

test_instances=( \
"memory_block_test" \
"single_lane_buffer_test" \
"multi_lane_buffer_test" \
"rho_buffer_test" \
"theta_test" \
"calculator_test" \
"slice_memory_test" \
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
