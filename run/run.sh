if [ ! -d "./my_work_dir" ]; then
    mkdir ./my_work_dir
fi

python3 ../include/mem_gen.py
python3 ../include/instr_converter.py

xrun -work WORK -access +r ../verify/testbench.v -l ./my_work_dir/xrun.log -xmlibdirpath ./my_work_dir +define+RTL_VERIFY > ./my_work_dir/run.log

# Check run.log for errors
if grep -q "\*E" ./my_work_dir/run.log; then
    echo "❌ Compilation fail due to errors:"
    grep "\*E" ./my_work_dir/run.log
    exit 1
else
    echo "✅ Test finished, no compilation errors found"
fi

if grep -q "\[ERROR\]" ./my_work_dir/run.log; then
    echo "❌ Runtime fail due to errors:"
    grep "\[ERROR\]" ./my_work_dir/run.log
    exit 1
else
    echo "✅ Test finished, no runtime errors found"
fi
