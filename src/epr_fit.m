% This matlab code was used to get final values for EPR spin-Hamiltonian parameters using EasySpin 6.0.0.
% Written by Felippe M. Colombari - LNBR/CNPEM (felippe.colombari@lnbr.cnpem.br)
% May, 2024

clear

% add path to easyspin exec
addpath 'C:\Users\felippe.colombari\easyspin-6.0.0\easyspin'

% read EPR data
[B,spc] = textread('EPR_WT_avicel.txt', '%s%s%*s%*s');
B   = str2double(B);
spc = str2double(spc);

% enter experimental conditions
Exp.nPoints     = 4096;
Exp.Range       = [220 370];  % mT
Exp.mwFreq      = 9.14;  % GHz
Exp.Temperature = 100; % K

Sys0.nPoints = 4096;
Sys0.Nucs = '63Cu';
Sys0.S = 1/2;

% enter initial guess values obtained previously
Sys0.lwpp    = [1 3];
Sys0.A       = [40, 40, 400];
Sys0.g       = [2.060, 2.060, 2.340];
Sys0.HStrain = [10, 10, 10];

% add upper and lower bounds...
Sys0VaryLB.A       = [5, 5, 375];
Sys0VaryUB.A       = [50, 50, 475];
Sys0VaryLB.g       = [2.000, 2.000, 2.280];
Sys0VaryUB.g       = [2.120, 2.120, 2.400];
Sys0VaryLB.HStrain = [10, 10, 10];
Sys0VaryUB.HStrain = [150, 150, 150];

% define fitting options
FitOpt.Method    = 'perturb2';
FitOpt.AutoScale = 'maxabs';
FitOpt.BaseLine  = 3;
FitOpt.maxTime   = 15;
FitOpt.Verbosity = 1; 

% first stage: global optimization with genetic algorithm
FitOpt.PopulationSize  = 20; %size of the population (number of parameter sets and simulations in one gen). Default value is 20; for fittings with many parameters, should be increased.
FitOpt.EliteCount      = 2 ; %number specifying the number of populations (ordered in terms of decreasing score) carried over to the next generation without recombination and mutation. 
FitOpt.maxGenerations  = 25; %A number specifying the maximum number of generations the algorithm should run. After this number has been reached, the algorithm terminates
FitOpt.TolFun          = 1e-5; %Termination tolerance for error function value (default = 1e-5).
FitOpt.RandomStart     = 0;
FitOpt.Method          = 'genetic fcn';
fit = esfit(spc, @pepper, {Sys0, Exp}, {Sys0VaryLB}, {Sys0VaryUB}, FitOpt);


% second stage: local optimization with Nelder-Mead downhill simplex algorithm
FitOpt.TolFun          = 1e-5 ; %Termination tolerance for error function value change (default = 1e-5).
FitOpt.delta           = 0.12  ; %Edge length of the initial simplex. The default value is 0.1.
FitOpt.TolEdgeLength   = 1e-4 ; %Termination tolerance for the length of the parameter step (default is 1e-4).
FitOpt.ScaleParams     = true ; %Rescale fitting parameters to within [-1,1] interval. Default is false.
FitOpt.RandomStart     = 0 ; 
Sys0                   = fit.argsfit{1};  % use fit result as starting point
FitOpt.Method          = 'simplex fcn';
fit = esfit(spc, @pepper, {Sys0, Exp}, {Sys0VaryLB}, {Sys0VaryUB}, FitOpt);

% save results on file
plot(B,fit.fit);
spc2=fit.fit;
data1 = [B(2:end) spc2(2:end)];
save('fitted_epr.txt','data1','-ascii');

fid = fopen('final_parameters.txt', 'w');
fprintf(fid,'Nucs         = %s\n', fit.argsfit{1}.Nucs);
fprintf(fid,'S            = %4.1f\n', fit.argsfit{1}.S);
fprintf(fid,'lwpp         = %6.4f %6.4f\n', fit.argsfit{1}.lwpp);
fprintf(fid,'A            = %9.5f %9.5f %9.5f\n', fit.argsfit{1}.A);
fprintf(fid,'g            = %12.9f %12.9f %12.9f\n', fit.argsfit{1}.g);
fprintf(fid,'HStrain      = %12.9f %12.9f %12.9f\n', fit.argsfit{1}.HStrain);
fprintf(fid,'nPoints      = %6i\n', fit.argsfit{2}.nPoints);
fprintf(fid,'Range        = %4i %4i\n', fit.argsfit{2}.Range);
fprintf(fid,'mwFreq       = %6.3f\n', fit.argsfit{2}.mwFreq);
fprintf(fid,'fit.rmsd     = %12.6f\n', fit.rmsd);
fprintf(fid,'fit.ssr      = %12.6f\n', fit.ssr);
fprintf(fid,'fit.rmsd     = %12.6f\n', fit.rmsd);
fprintf(fid,'fit.redchisq = %12.6f\n', fit.redchisquare);
fid=fclose(fid);

full_plot = plot(B,spc,B,spc2);
saveas(gcf, 'final_fit.png', 'png');
