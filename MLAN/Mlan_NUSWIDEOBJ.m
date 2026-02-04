clear all;
addpath(genpath('./utils/'));
addpath(genpath('MLAN/model/'));


%%必改
dataName = 'NUSWIDEOBJ';
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
options.lambda = 1e-3;
options.k = 9;
options.maxIter = 2;

[F] = MLAN(data, truth, options);


