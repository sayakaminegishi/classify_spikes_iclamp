% MapMySpikes Project - goal 1 - prediction of VISPviewer T type from
% numerical properties in the same spreadsheet
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

%remove cell ID, sex, vispviewerTtype from common input variables
idx = strcmp(VISpVars, 'CellID')|strcmp(VISpVars, 'Sex')|strcmp(VISpVars, 'VISpViewerTType')|strcmp(VISpVars, 'VISpViewerMETType')|strcmp(VISpVars,'TTypeClass')|strcmp(VISpVars,'TTypeSubclass')|strcmp(VISpVars, 'TTypeAssignmentProbability')|strcmp(VISpVars,'CorticalLayer')|strcmp(VISpVars, 'Genotype_full_')|strcmp(VISpVars, 'AnatomicalStructure')|strcmp(VISpVars, 'BrainHemisphere')|strcmp(VISpVars, 'FluorescentProteinPositive');
VISpVars = VISpVars(~idx);

display(VISpVars)

% input tables for VISp and CTKE
X_VISp = extract_columns(VISp_Viewer, VISpVars);

X_VISp = table2array(X_VISp); %convert table to array format so it can be processed

%% analysis
%Mdl is a trained ClassificationKNN classifier
%Mdl = fitcknn(X_VISp,Y_VispViewerTType1,'NumNeighbors',5,'Standardize',1)

%find trained model by automatically optimizing hyperparametesr 
rng(200)
Mdl = fitcknn(X_VISp,Y_VispViewerTType1,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus')) %our classifier


%predict the classifications with min, mean and max charactersitics
Xnew = [min(X_VISp);mean(X_VISp);max(X_VISp)];
[label,score,cost] = predict(Mdl,Xnew)


%% examine quality of KNN classifier
rloss = resubLoss(Mdl)

CVMdl = crossval(Mdl);
kloss = kfoldLoss(CVMdl)

%K=3;
% [idx,c] = kmeans(X_VISp,K);
% 
% figure(102);
% 
% clf; % clear the figure;
% 
% vlt.plot.scatterplot(X_VISp,'class',idx,'markersize',4,'marker','o');
% 
% vlt.plot.scatterplot(c,'class',[1:size(c,1)]','marker','o','markersize',8,'shrink',0);
% 
% %here, small open circles correspond to individual datapoints and the large open circles correspond to the cluster centers.
% vlt.stats.kmeans_over_time(X_VISp,4);
% 
% 
% 
% 
% 
% 

% %PERFORM DIMENSIONALITY REDUCTION
% rng(8000,'twister')
% holdoutCVP = cvpartition(Y_VispViewerTType1,'holdout',56)
% dataTrain = X_VISp(holdoutCVP.training,:);
% grpTrain = Y_VispViewerTType1(holdoutCVP.training);
% 
% %sort
% dataTrainG1 = dataTrain(grp2idx(grpTrain)==1,:);
% dataTrainG2 = dataTrain(grp2idx(grpTrain)==2,:);
% [h,p,ci,stat] = ttest2(dataTrainG1,dataTrainG2,'Vartype','unequal');
% [~,featureIdxSortbyP] = sort(p,2); % sort the features
% testMCE = zeros(1,14);
% resubMCE = zeros(1,14);
% nfs = 5:5:70;
% classf = @(xtrain,ytrain,xtest,ytest) ...
%              sum(~strcmp(ytest,classify(xtest,xtrain,ytrain,'quadratic')));
% resubCVP = cvpartition(length(Y_VispViewerTType1),'resubstitution')         
% 
% 
% tenfoldCVP = cvpartition(grpTrain,'kfold',10)
% 
% fs1 = featureIdxSortbyP(1:35);
% 
% fsLocal = sequentialfs(classf,dataTrain(:,fs1),grpTrain,'cv',tenfoldCVP);
% 
% fs1(fsLocal)
% % 
% % %,'ClassNames',{'APAmplitude_mV_', 'APThreshold_mV_','APWidth_ms_', 'Age_postnatalDays_', 'InputResistance_M__', 'ReboundAPs_number_', 'RestingMembranePotential_mV_','SagRatio'});
% % 
% % %%%%%%%%%%%%%%% fit model for VISp dataset - k nearest neighboR %%%%%%
% % rng(10); %for reproducibility
% % Mdl_VISp = fitcknn(X_VISp, Y_VispViewerTType1,'NumNeighbors',5,'Standardize',1) %construct KNN model
% % 
% % %%%%  check quality of model %%%%%
% % rloss_VISp = resubLoss(Mdl_VISp) %percent of training data that the classifier predicts incorrectly. resubstitution loss.
% % CVMdl_VISp = crossval(Mdl_VISp, 'KFold',5); %Construct a cross-validated classifier from the model.
% % kloss_VISp = kfoldLoss(CVMdl_VISp) %cross-validation loss. average loss of each cross-validation model when predicting on data that is not used for training.
% % 
% % %type: Mdl_VISp.Prior to get prior probabilities of each class
% % 
% % % predict the classification of an average spike, X_VISp
% % avgX_VISp = mean(X_VISp)
% % 
% % avgX_VISp_class = predict(Mdl_VISp,avgX_VISp)
% % 
% % 
% % %%%%%%%%%%%%
% % CMdl = fitcknn(X_VISp,Y_VispViewerTType1,'NSMethod','exhaustive','Distance','mahalanobis');
% % CMdl.NumNeighbors = 3;
% % closs = resubLoss(CMdl)