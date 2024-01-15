#!/bin/bash
##installing pip for python if not already 
sudo upt-get update
sudo apt-get install python3
sudo apt-get install python3-pip
sudo apt-get install python3-venv
python3 -m pip install --upgrade pip setuptools
cd ../..
##cloning the PET repository
git clone git@github.com:Python-Ensemble-Toolbox/PET.git PET

##create a PET virtual enviornmnet in venv-PET folder
python3 -m venv venv-PET
##acrivate the envirnment
source venv-PET/bin/activate
##some pre-requisites that do not work out of the box
##python3 -m pip install --upgrade pip setuptools
python3 -m pip install wheel
python3 setup.py bdist_wheel
##install PET in the newly created enviornment ("PET" is the relative path to the PET folder)
python3 -m pip install -e PET

##cloning NonstationaryGAN
git clone git@github.com:ai4netzero/NonstationaryGANs.git

##installing packages for NonstationaryGAN
