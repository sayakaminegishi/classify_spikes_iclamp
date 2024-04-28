% MapMySpikes Project - CTKE prediction
%prediction of CTKE T Type from numerical properties in the same spreadsheet
% initial attempt using most of the variables as a classifier

%todo: ask whether this is correct

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
VISpVars = CTKE_M1.Properties.VariableNames; %column names of VISp

%remove cell ID, sex, vispviewerTtype from common input variables
idx = strcmp(VISpVars, 'CellID')|strcmp(VISpVars, 'CTKETType')|strcmp(VISpVars, 'RNAFamily_subclass_')|strcmp(VISpVars, 'VISpViewerTType')|strcmp(VISpVars, 'Sex')|strcmp(VISpVars, 'MouseGenotype')|strcmp(VISpVars, 'TargetedLayer')|strcmp(VISpVars, 'InferredLayer')|strcmp(VISpVars,'Cre__Or__')|strcmp(VISpVars,'RNAFamily_subclass')|strcmp(VISpVars, 'CTKETTypeConfidence')|strcmp(VISpVars,'CTKETTypeTop_3_TopThreeMappingM1CellTypesFromCTKEWithBootstrap_')|strcmp(VISpVars, 'VISpViewerTTypeTop_3_TopThreeMappingVISp_ALMCellTypesFromTasicE');
VISpVars = VISpVars(~idx);

display(VISpVars)

% input tables for VISp and CTKE
X_VISp = extract_columns(CTKE_M1, VISpVars);

X_VISp = table2array(X_VISp); %convert table to array format so it can be processed

%% analysis
%Mdl is a trained ClassificationKNN classifier
%Mdl = fitcknn(X_VISp,Y_VispViewerTType1,'NumNeighbors',5,'Standardize',1)

%find trained model by automatically optimizing hyperparametesr 
rng(60)
Mdl = fitcknn(X_VISp,Y_CTKETType,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus')) %our classifier


%predict the classifications with min, mean and max charactersitics
Xnew = [min(X_VISp);mean(X_VISp);max(X_VISp)];
[label,score,cost] = predict(Mdl,Xnew)


%% examine quality of KNN classifier
rloss = resubLoss(Mdl)

CVMdl = crossval(Mdl);
kloss = kfoldLoss(CVMdl)

