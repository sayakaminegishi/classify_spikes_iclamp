% MapMySpikes Project - goal 1

% Created by: Sayaka (Saya) Minegishi
% Contact: minegishis@brandeis.edu
% Date: Apr 24, 2024

%table from each query (X - input)
Query1_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query1');
Query2_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query2');
Query3_data = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'Query3');

%cell type columns (Y - response):
CTKE_M1 = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'CTKE_M1');
VISp_Viewer = readtable('MapMySpikes_data_PUBLIC final.xlsx', 'Sheet', 'VISp_Viewer');



