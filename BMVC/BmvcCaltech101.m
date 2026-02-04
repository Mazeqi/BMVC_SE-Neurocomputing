clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC/model/'));

%%必改
dataName = 'Caltech101';
algorithmName = 'Bmvc';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['BMVC/data_anchors/', 'Anchor_', dataName, '.mat'];
load(dataAnchor);

data = X;
truth = Y;
clear X Y

numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.selIndex = 4;
options.beta=0.003;       % Hyper-para beta
options.gama=1e-2;         % Hyper-para gamma
options.lambda=0.00001;  % Hyper-para lambda
options.MaxIter = 30;
 options.bR = 128;
[predLabels] = BMVC(data, Anchor, truth, options);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f\n\n, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
