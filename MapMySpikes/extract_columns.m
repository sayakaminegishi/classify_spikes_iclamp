function newTable = extract_columns(table, columnNamesSet)

%this function makes a new table containing columns of interest. Contains
%all rows.
%table = original table
%columnNamesSet = set {} of column names to include in new table

% Created by: Sayaka (Saya) Minegishi
% Contact: minegishis@brandeis.edu
% Last Updated: Apr 24, 2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%make a new table containing only the columns we want to examine
originalTable = table;

% Specify the column names you want to examine
columnsToExamine = columnNamesSet; %{'Column1', 'Column2', 'Column3'};

% Create a new table containing only the specified columns
newTable = originalTable(:, columnsToExamine);


end