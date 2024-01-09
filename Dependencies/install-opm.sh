#!/bin/bash
##OPM installation
sudo apt-get update
##upgrading to latest libraries (might be skipped)
sudo apt-get upgrade
sudo apt-get install software-properties-common
##adding OPM repositories
sudo apt-add-repository ppa:opm/ppa
sudo apt-get update
##adding mpi prerequisites. One needs an MPI installed, but can choose a different version.
sudo apt-get install mpi-default-bin
##installing OPM including OPM flow
sudo apt-get install libopm-simulators-bin

