clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC/model/'));

%%必改
dataName = 'CCV';
algorithmName = 'Bmvc';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
load(dataAnchor);

% %-------transform data ->(numInst, numFea)
numView = length(data)
for iView = 1:numView
    data{iView} = data{iView}'; 
end

truth = truelabel{1};
clear truelabel

numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.selIndex = 2;
options.beta=1e-1;       % Hyper-para beta
options.gama=1e-1;         % Hyper-para gamma
options.lambda=0.00001;  % Hyper-para lambda
options.MaxIter = 30;
options.bR  = 128;
[predLabels] = BMVC(data, Anchor, truth, options);

resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
