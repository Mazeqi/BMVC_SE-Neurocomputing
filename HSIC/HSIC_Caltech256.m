clear all;
addpath(genpath('./utils/'));
addpath(genpath('HSIC/model/'));

%%必改
dataName = 'Caltech256_fea';
algorithmName = 'HSIC';

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

options.beta = 1e-2;       % Hyper-para beta
options.gamma = 1e-2;     % Hyper-para gamma
options.lambda = 1e-5; % Hyper-para lambda

options.maxIters = 20;
options.selIndex = 3;
options.truth = truth;
[predLabels] = HSIC(data, Anchor, options);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
