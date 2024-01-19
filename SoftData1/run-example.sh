cd data
python setup.py
cd ..
cp ../HardData/posterior_state_estimate.npz prior.npz
python run_script.py
python ../Plotting/plotting.py ../SoftData1
