## SoftData Case 2

To run the complete example, you can use a full script that combines the steps below

```
chmod +x run-example.sh
./run-example.sh
```

### Steps in the example script

1. Generate the data by running building and running the data-generating model inside the data folder. This is achieved
by running the following command in the data folder:
```
cd data
python setup.py
cd ..
```
2. Copy the posterior estimate from the HardData run into this folder and rename to prior.npz. In the terminal run:
```
cp ../HardData/posterior_state_estimate.npz prior.npz
```
3. Run the inversion by running the following command:
```
python run_script.py
```


4. To plot the results, run

```
python ../Plotting/plotting.py ../SoftData2
```
