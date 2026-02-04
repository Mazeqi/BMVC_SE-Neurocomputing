clear all;  clear memory;
addpath(genpath('./utils/'));
addpath(genpath('HSIC/model/'));

%%必改
dataName = 'YoutubeFace_sel_fea';
algorithmName = 'HSIC';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_', dataName, '.mat'];
load(dataAnchor);

resultDir = [ 'Results/ResultTabels/',  dataName, '/', '/',algorithmName, '/'];
if(~exist(resultDir,'file'))
    mkdir(resultDir);
end

numView = length(X)
numInst = size(X{1}, 1)
numClust = numel(unique(Y))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.selIndex = 3;

[pred_label] = HSIC(X, Anchor, options);

meanResult = ClusteringMeasure(Y, pred_label);

fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f\n\n',meanResult(1),meanResult(2),meanResult(3));
save([resultDir, dataName, '_result.mat'], 'meanResult');

%[dim, N] = size(X{1});
%[~,label] = max(G,[],1);
%res_cluster = ClusteringMeasure(gnd, label);
% [fm, Precision, Recall] = compute_f(gnd, label'); 
% fprintf('ACC = %.4f and NMI = %.4f, Purity = %.4f, F-Score = %.4f\n\n',res_cluster(1),res_cluster(2),res_cluster(3),fm);
