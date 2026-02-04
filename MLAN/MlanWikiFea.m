clear all;
addpath(genpath('./utils/'));
addpath(genpath('MLAN/model/'));


%%必改
dataName = 'Wiki_fea';
algorithmName = 'BmvcSpectral';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

data = X;
truth = Y;
clear X Y

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
%All view results: ACC = 0.4431 and NMI = 0.4402, Purity = 0.5066
options.lambda = 1e-3;
options.k = 9;
options.maxIter = 3;

[F] = MLAN_high_storage(data, truth, options);


