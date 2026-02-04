clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC_Spectral/model_B1/'));

%%必改
dataName = 'Animal';
algorithmName = 'BmvcSpectral';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
load(dataAnchor);

truth = '';
if strcmp(dataName, 'CCV') == 1
    % %-------transform data ->(numInst, numFea)
    numView = length(data);
    for iView = 1:numView
        data{iView} = data{iView}'; 
    end

    truth = truelabel{1};
    clear truelabel
else
    data = X;
    truth = Y;
    clear X Y
end

if strcmp(dataName, 'NUSWIDEOBJ') == 1
    options.lambda1 = 1e-5;
    options.lambda2 = 1e-5;
    options.selIndex = 5;
    options.r = 5;
    options.dataName = 'NUSWIDEOBJ';
end

if strcmp(dataName, 'Caltech101') == 1
    options.selIndex = 5;
    options.r = 5;
    options.lambda1 = 1e-5;
    options.lambda2 = 1e-5;
    options.dataName = 'Caltech101';
end

if strcmp(dataName, 'Animal') == 1
    options.selIndex = 2;
    options.r = 5;
    options.lambda1 = 1e-3;
    options.lambda2 = 1e-5;
    options.dataName = 'Animal';
end

if strcmp(dataName, 'CCV') == 1
    options.selIndex = 2;
    options.r = 5;
    options.lambda1 = 1e-4;
    options.lambda2 = 1e3;
    options.dataName = 'CCV';
end

if strcmp(dataName, 'Hdigit') == 1
    options.selIndex = 2;
    options.r = 5;
    options.lambda1 = 1e-5;
    options.lambda2 = 1e-5;
    options.dataName = 'Hdigit';
end

if strcmp(dataName, 'Wiki_fea') == 1
    options.selIndex = 2;
    options.r = 5;
    options.lambda1 = 0.001;
    options.lambda2 = 0.001;
    options.dataName = 'Wiki_fea';
end
numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda3 = 1e-5;
options.maxIters = 50;

[resultTable] = BmvcSpectral_Experiment_Object(data, Anchor, truth, options);

resultDir = [ 'Results/ObjectValue/'];
if(~exist(resultDir,'file'))
    mkdir(resultDir);
end
save([resultDir, dataName, '_result.mat'], 'resultTable');
