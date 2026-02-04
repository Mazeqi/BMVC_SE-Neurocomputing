clear all;
addpath(genpath('./utils/'));
addpath(genpath('MLAN/model/'));

%%必改
dataName = 'CCV';
algorithmName = 'Mlan';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

% %-------transform data ->(numInst, numFea)
numView = length(data)
for iView = 1:numView
    data{iView} = data{iView}'; 
end

truth = truelabel{1};
clear truelabel

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda = 1e-3;
options.k = 9;
options.maxIter = 20;

[F] = MLAN(data, truth, options);


