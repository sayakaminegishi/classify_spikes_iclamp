% MapMySpikes Project - goal 1
% initial attempt using most of the variables as a classifier

% Created by: Sayaka (Saya) Minegishi
% Contact: minegishis@brandeis.edu
% Date: Apr 24, 2024
clear all
close all

mydirname = '/Users/sayakaminegishi/MATLAB/tools'
p = genpath(mydirname)
addpath(genpath(mydirname))

%table from each query 
Query1_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query1');
Query2_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query2');
Query3_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query3');

%cell type columns 
CTKE_M1 = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'CTKE_M1');
VISp_Viewer = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'VISp_Viewer');

CTKE_M1 = rmmissing(CTKE_M1);
VISp_Viewer = rmmissing(VISp_Viewer);


% response variables:

Y_VispViewerTType1 = VISp_Viewer(:,2); %cell type in VISP
Y_CTKETType = CTKE_M1(:,2);
Y_VispViewerTType2 = CTKE_M1(:,3);

Y_VispViewerTType1 = table2array(Y_VispViewerTType1); %convert to array format so it can be processed
Y_CTKETType = table2array(Y_CTKETType);
Y_VispViewerTType2 = table2array(Y_VispViewerTType2);

%X - input variables:
%first find input variables common in both VISp and CTKE sheets
VISpVars = VISp_Viewer.Properties.VariableNames; %column names of VISp

commonVars = {'APAmplitude_mV_', 'APThreshold_mV_','APWidth_ms_', 'Age_postnatalDays_', 'InputResistance_M__', 'ReboundAPs_number_'};

% input tables for VISp and CTKE
X_VISp = extract_columns(VISp_Viewer, commonVars);

X_VISp = table2array(X_VISp); %convert table to array format so it can be processed

%% analysis
%Mdl is a trained ClassificationKNN classifier
%Mdl = fitcknn(X_VISp,Y_VispViewerTType1,'NumNeighbors',5,'Standardize',1)

%find trained model by automatically optimizing hyperparametesr 
rng(1)
Mdl = fitcknn(X_VISp,Y_VispViewerTType1,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus')) %our classifier


%predict the classifications with min, mean and max charactersitics
Xnew = [min(X_VISp);mean(X_VISp);max(X_VISp)];
[label,score,cost] = predict(Mdl,Xnew)


%% examine quality of KNN classifier
rloss = resubLoss(Mdl)

