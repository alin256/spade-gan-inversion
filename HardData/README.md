## HardData
Both the data and the prior model are part of the repository. 

To run the complete example, you can use a full script that combines the steps below

```
chmod +x run-example.sh
./run-example.sh
```

### Steps in the example script

1. Activate the Python environment configured for PET. If you followed the installation script it would be done using the following command: 

```
source ../../venv-PET/bin/activate
```

2. To run the inversion, one must run the following command:

```
python run_script.py
```

3. To plot the results, run

```
python ../Plotting/plotting.py ../HardData
```
