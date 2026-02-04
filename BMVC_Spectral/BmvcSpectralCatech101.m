clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC_Spectral/model_B1/'));

%%必改
dataName = 'Caltech101';
algorithmName = 'BmvcSpectral';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
load(dataAnchor);

% %-------transform data ->(numInst, numFea)
% numView = length(data)
% for iView = 1:numView
%     data{iView} = data{iView}'; 
% end

data = X;
truth = Y;
clear X Y

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda1 = 1e-5;
options.lambda2 = 1e-5;
options.lambda3 = 1e-6;
options.selIndex = 5;
options.r = 4;
options.maxIters = 20;
options.bR = 128;
options.maxNgIters = 8;
%[pred_label, resultB] = BmvcSpectral_RL(data, Anchor, truth, options);

[predLabels, resultB] = BmvcSpectral_random_diff(data, Anchor, truth, options);

resultDir = ['Results/TSNE_B/'];
if(~exist(resultDir,'file'))
    mkdir(resultDir);
end
%save([resultDir, dataName, '_B.mat'], 'resultB');
%resCluster = ClusteringMeasure(truth, predLabels);
%fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
