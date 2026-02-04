clear;  clear memory; clc;
addpath(genpath('./utils/'));

% NUSWIDEOBJ Caltech101 Wiki_fea Caltech256 Caltech101-20 cifar10
dataName = 'Wiki_fea'

n_anchors = 1000;

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin)

%----wiki data X : [nsmp, nfea] Y:[nsmp]
%----Caltech101 data X : [nsmp, nfea] Y:[nsmp]
%----Hdigit data X : [nsmp, nfea] Y:[nsmp]
%----Animal data X : [nsmp, nfea] Y:[nsmp]
%----NUSWIDEOBJ data X : [nsmp, nfea] Y:[nsmp]
%----CCV data X : [nfea, nsmp] truelabe{1}:[nsmp]


data = X;
%truth = truelabel{1};
truth = Y;
clear X Y

%----------------------Caltech101 NUSWIDEOBJ--------------------%
numView = length(data)
numInst = length(truth)

%-------------gen anchor---------------%
if size(data{1}, 1) < size(data{1}, 2)
    for iView = 1:numView
        data{iView} = data{iView}';
    end
end
    
Anchor = cell(numView, 1);
XX = [];
for v = 1:numView
    XX = [XX data{v}];
end

[~,ind,~] = VDA(XX, n_anchors);
for v = 1:numView
    Anchor{v} = data{v}(ind, :);
end


%-------------save anchor
resultDir = 'data_anchors/'
save([resultDir, 'Anchor_Vda_', dataName, '.mat'], 'Anchor');