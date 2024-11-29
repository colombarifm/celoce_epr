# celoce_epr

This repository contains two scripts used for the analysis of EPR spectrum of CelOCE.    
Both codes ran on a Intel Core i7-10510U laptop (max 2.30 GHz, 16 GB RAM) running Windows 10.

## epr_initial_guess.ipynb

This Python notebook was used to get reasonable initial values for EPR spin-Hamiltonian parameters prior to EasySpin simulations. These initial parameters were estimated based on geometrical attributes of each spectrum.    
The demo example found in demo/EPR_WT_avicel.txt should in a few seconds, and will generate plots with the geometrical considerations for both A and g tensors highlighted, along with their estimated values.    
Code tested with VSCode 1.95.3, running python 3.12.3 within a conda environment. The following package versions were used:

* Pandas 2.2.1    
* Numpy 1.26.4           
* SciPy 1.13.0    
* Matplotlib 3.8.4    

## epr_fit.m

This Matlab code was used as a wrapper to set all required EasySpin simulation parameters and run the simulations.    
As an example, after setting the path to your EasySpin directory installation

    % add path to easyspin exec    
    addpath 'C:\path\to\easyspin'

and read the same demo spectrum used previously

    % read EPR data    
    [B,spc] = textread('demo/EPR_WT_avicel.txt', '%s%s%*s%*s');

the appropriate initial values for both A and g tensors (estimated previously) can be set

    % enter initial guess values obtained previously from epr_initial_guess output    
    Sys0.A       = [40, 40, 400];    
    Sys0.g       = [2.06, 2.06, 2.34];    

Upon execution, it will run a two-stage EasySpin optimization to get final values for EPR spin-Hamiltonian parameters. The whole process should run in about 10 minutes and will generate a XY file containing data for the fitted EPR spectrum along with another text file containing final values for A and g tensors.    
This code was tested with Matlab R2022b and EasySpin 6.0.0

