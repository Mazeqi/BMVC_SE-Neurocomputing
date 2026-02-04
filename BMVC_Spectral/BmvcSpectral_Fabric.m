clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC_Spectral/model_B1/'));

%%必改
dataName = 'fabric';
algorithmName = 'BmvcSpectral';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

dataAnchor = ['data_anchors/', 'Anchor_Kmean_', dataName, '.mat'];
load(dataAnchor);

% %-------transform data ->(numInst, numFea)
% numView = length(data)
% for iView = 1:numView
%     data{iView} = data{iView}'; 
% end

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

length(randIndexSelect)

numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;
options.lambda1 = 1e-2;
options.lambda2 = 1e-2;
options.lambda3 = 1e-5;
options.maxIters = 50;
options.selIndex = 1;
options.r = 5;
% -2 -2
options.bR = 128;
options.maxNgIters = 8;
%[pred_label, resultB] = BmvcSpectral_RL(data, Anchor, truth, options);

[pred_label, resultB] = BmvcSpectral(data, Anchor, truth, options);
resultDir = ['Results/TSNE_B/'];
if(~exist(resultDir,'file'))
    mkdir(resultDir);
end
save([resultDir, dataName, '_B.mat'], 'resultB');