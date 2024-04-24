% MapMySpikes Project - goal 1
% initial attempt using most of the variables as a classifier

% Created by: Sayaka (Saya) Minegishi
% Contact: minegishis@brandeis.edu
% Date: Apr 24, 2024

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
CTKEVars = CTKE_M1.Properties.VariableNames;
commonVars = intersect(VISpVars, CTKEVars); %column names common in both VISP and CTKE

%remove cell ID, sex, vispviewerTtype from common input variables
idx = strcmp(commonVars, 'CellID')|strcmp(commonVars, 'Sex')|strcmp(commonVars, 'VISpViewerTType');
commonVars = commonVars(~idx);

display(commonVars)

% input tables for VISp and CTKE
X_VISp = extract_columns(VISp_Viewer, commonVars);
X_CTKE = extract_columns(CTKE_M1, commonVars);

X_VISp = table2array(X_VISp); %convert table to array format so it can be processed
X_CTKE = table2array(X_CTKE);

%,'ClassNames',{'APAmplitude_mV_', 'APThreshold_mV_','APWidth_ms_', 'Age_postnatalDays_', 'InputResistance_M__', 'ReboundAPs_number_', 'RestingMembranePotential_mV_','SagRatio'});

%fit model for VISp dataset - k nearest neighbor
rng(10); %for reproducibility
Mdl_VISp = fitcknn(X_VISp, Y_VispViewerTType1,'NumNeighbors',4,'Standardize',1) %construct KNN model

%%%%  check quality of model %%%%%
rloss_VISp = resubLoss(Mdl_VISp) %percent of training data that the classifier predicts incorrectly. resubstitution loss.
CVMdl_VISp = crossval(Mdl_VISp); %Construct a cross-validated classifier from the model.
kloss_VISp = kfoldLoss(CVMdl_VISp) %cross-validation loss. average loss of each cross-validation model when predicting on data that is not used for training.

%type: Mdl_VISp.Prior to get prior probabilities of each class

% predict the classification of an average spike, X_VISp
avgX_VISp = mean(X_VISp)

avgX_VISp_class = predict(Mdl_VISp,avgX_VISp)