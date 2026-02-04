clear all;
addpath(genpath('./utils/'));
addpath(genpath('HSIC/model/'));

%%必改
dataName = 'fabric';
algorithmName = 'HSIC';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
load(dataAnchor);

truth = Y';
clear Y

randLabelSelect = 0:7
randIndexSelect = [];
for ind = 1:length(randLabelSelect)
    newRandList = find(truth==randLabelSelect(ind));
    if length(newRandList) > 7000
        newRandList = newRandList(1:1000);
    end
    randIndexSelect = [randIndexSelect; newRandList];
end

data{1} = X_1(randIndexSelect, :)*10;
data{2} = X_2(randIndexSelect, :)*10;
truth = truth(randIndexSelect, :);
clear X_1 X_2

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;

options.beta = 1e-3;       % Hyper-para beta
options.gamma = 1e-3;     % Hyper-para gamma
options.lambda = 1e-5; % Hyper-para lambda
options.bR = 128;
options.maxIters = 10;
options.selIndex = 1;
options.truth = truth;
[predLabels] = HSIC(data, Anchor, options);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
