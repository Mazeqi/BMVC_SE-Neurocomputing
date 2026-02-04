clear all;
addpath(genpath('./utils/'));
addpath(genpath('MLAN/model/'));


%%必改
dataName = '100Leaves';
algorithmName = 'Mlan';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);
numView = length(data)
for iView = 1:numView
    data{iView} = data{iView}'; 
end
numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda = 1e-2;
options.k = 9;
options.maxIter = 20;

[F] = MLAN(data, truth, options);


