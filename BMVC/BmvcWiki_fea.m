clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC/model/'));

%%必改
dataName = 'Wiki_fea';
algorithmName = 'Bmvc';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
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
options.selIndex = 2;
options.beta=300;       % Hyper-para beta
options.gama=1e-3;         % Hyper-para gamma
options.lambda=0.00001;  % Hyper-para lambda
options.MaxIter = 30;
options.bR = 128; 
% All view results: ACC = 0.5174 and NMI = 0.4529, Purity = 0.5583
 
[predLabels] = BMVC(data, Anchor, truth, options);

resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f\n\n, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
