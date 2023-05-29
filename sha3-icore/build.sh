#START OF CONFIGURATION BLOCK
#EDIT PROJECT SOURCES HERE

#relative to the "src" directory
sources=( \
"interface/Atom" \
"types" \
"util" \
"modules/memory/memory_block" \
"modules/memory/manual_port_memory_block" \
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
"modules/gamma_calculator/gamma_calculator" \
"modules/purger" \
"modules/reader" \
"modules/writer" \
"modules/sha3_atom_controller" \
"sha3_atom" \
"dynamic_iterator_atom" \
)

#relative to the "simulation" directory
simulation_sources=( \
"slice_memory_wrapper" \
)

#relative to the "test" directory
#TEST INSTANCES MUST NOT BE IN ANY SUBDIRECTORY 
test_instances=( \
"slice_memory_test" \
"memory_block_test" \
"single_lane_buffer_test" \
"multi_lane_buffer_test" \
"rho_buffer_test" \
"theta_test" \
"single_slice_calculator_test" \
"gamma_calculator_test" \
)

#relative to the "test_src" directory
test_sources=( \
"test_types" \
"test_util" \
"test_data" \
"visualizer" \
)

#END OF CONFIGURATION BLOCK
#LEAVE THE REST AS IS

src_dir=$(pwd)/src
sim_dir=$(pwd)/simulation
test_dir=$(pwd)/test
test_src_dir=$(pwd)/test_src

echo export test instances
mkdir -p ../build/sha3-icore
echo ${test_instances[@]} > ../build/sha3-icore/test_instances

pushd . > /dev/null
cd ../build/sha3-icore
echo clear icore work directory
rm -r -f ./work

echo build simulation sources
for f in ${simulation_sources[@]}; do
nvc -a "${sim_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build simulation ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

echo build icore sources
for f in ${sources[@]}; do
nvc -a "${src_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build source ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

echo build vhdl test sources
for f in ${test_sources[@]}; do
nvc -a "${test_src_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build test source ${f}\e[0m"
popd > /dev/null
exit 1
fi
done

echo build vhdl test instances
for f in ${test_instances[@]}; do
nvc -a "${test_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo -e "\e[31mfailed to build test instance ${f}\e[0m"
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
