## SoftData Case 1

To run the soft data case 1, one must do the following:
1. Generate the data by running building and running the data-generating model inside the data folder. This is achieved
by running the following command in the data folder:
```
python setup.py
```
2. Copy the posterior estimate from the HardData run into this folder and rename to prior.npz. In the terminal run:
```
cp ../HardData/posterior_state_estimate.npz prior.npz
```
3. Run the inversion by running the following command:
```
python run_script.py
```

