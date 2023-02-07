
pushd . > /dev/null

cd ../build/sha3-icore
echo read test instances
test_instances=$(<./test_instances)

echo run icore tests
failed_tests=0
passed_tests=0
total_tests=0

for f in ${test_instances[@]}; do
((total_tests++))
echo -n [${f}]
nvc -r -w ${f}
failed=$?
if [ $failed -ne 0 ]; then
((failed_tests++))
echo failed
else
((passed_tests++))
echo ok
fi
done
echo executed ${total_tests} tests
echo passed: ${passed_tests}
echo failed: ${failed_tests}
popd > /dev/null
exit $([ $failed_tests -ne 0 ] && echo 1 || echo 0)
