clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC_Spectral/model_B1/'));

%%必改
dataName = 'Caltech101';
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
    options.selIndex = 5;
    options.r = 5;
    options.dataName = 'NUSWIDEOBJ';
end

if strcmp(dataName, 'Caltech101') == 1
    options.selIndex = 5;
    options.r = 4;
    options.dataName = 'Caltech101';
end

if strcmp(dataName, 'Animal') == 1
    options.selIndex = 2;
    options.r = 2;
    options.dataName = 'Animal';
end

if strcmp(dataName, 'Wiki_fea') == 1
    options.selIndex = 2;
    options.r = 5;
    options.dataName = 'Wiki_fea';
end

numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda3 = 1e-5;
options.maxIters = 20;

parameterRange = [1e-5, 1e+5];
paraLambdaPaper1 = parameterRange(1);
paraLambdaTop = parameterRange(2);

resultTable = zeros(121, 6);
indRow = 1;

while paraLambdaPaper1 <= paraLambdaTop
    %論文中的lam1 lam2與這裡相反
    options.lambda2 = paraLambdaPaper1;
    paraLambdaPaper2 = parameterRange(1);
    
    while paraLambdaPaper2 <= paraLambdaTop
        options.lambda1 = paraLambdaPaper2;
        % 清空控制台
        clc
        indRow
        [bestResults] = BmvcSpectral_Experiment_lr(data, Anchor, truth, options);
        
        resultTable(indRow, 1) = paraLambdaPaper1;
        resultTable(indRow, 2) = paraLambdaPaper2;
        resultTable(indRow, 3) = bestResults{1};
        resultTable(indRow, 4) = bestResults{2};
        resultTable(indRow, 5) = bestResults{3};
        resultTable(indRow, 6) = bestResults{4};
        indRow = indRow + 1;
        paraLambdaPaper2 = paraLambdaPaper2*10;
    end
    paraLambdaPaper1 = paraLambdaPaper1 * 10;
end
resultDir = [ 'Results/Para3DTable/'];
if(~exist(resultDir,'file'))
    mkdir(resultDir);
end
save([resultDir, dataName, '_result.mat'], 'resultTable');
