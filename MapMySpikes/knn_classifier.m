% MapMySpikes Project - goal 1
% initial attempt using most of the variables as a classifier

% Created by: Sayaka (Saya) Minegishi
% Contact: minegishis@brandeis.edu
% Date: Apr 24, 2024


%%%%%%%%%%%%% Extract data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


%%%%%%%%%%%%%%%%% X_VISp %%%%%%%%%%%%%%%%
% Perform PCA
[coeff, score, ~, ~, explained] = pca(X_VISp);

% Choose the number of principal components to retain
num_components = 2; % Choose based on explained variance or other criteria

% Project data onto the selected principal components
X_pca = score(:, 1:num_components);


% Split data into training and testing sets (70% training, 30% testing)
rng(42); % Set random seed for reproducibility
cv = cvpartition(size(X_pca, 1), 'Holdout', 0.3);
X_train = X_pca(training(cv), :);
Y_train = Y_VispViewerTType1(training(cv));
X_test = X_pca(test(cv), :);
Y_test = Y_VispViewerTType1(test(cv));

% Train kNN classifier
k = 5; % Number of neighbors
mdl_VISp = fitcknn(X_train, Y_train, 'NumNeighbors', k)

% Predict class labels for testing set
Y_pred = predict(mdl_VISp, X_test)

% Evaluate performance
accuracy = sum(string(Y_pred) == string(Y_test)) / numel(Y_test);
conf_matrix = confusionmat(Y_test, Y_pred);

% Display results
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
