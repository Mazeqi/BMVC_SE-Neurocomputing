clear;  clear memory; clc;
addpath(genpath('/home/tanpengjie1/Mazeqi/matlab/multi-view/large_scale_multi_view_ori/utils/'));

% NUSWIDEOBJ Caltech101 Wiki_fea Caltech256 Caltech101-20 cifar10
dataName = 'fabric'

n_anchors = 1000;
rand('seed',100);

dataOrigin = ['/home/tanpengjie1/Mazeqi/matlab/multi-view/dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin)



if strcmp(dataName, 'fabric') == 1
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
    
    data{1} = X_1(randIndexSelect, :);
    data{2} = X_2(randIndexSelect, :);
    truth = truth(randIndexSelect, :);
    clear X_1 X_2
else
    %data = +X;
    data{1} = X_1;
    data{2} = X_2;
    
    %truth = truelabel{1};
    truth = Y';
    % clear X Y
end

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
for iView = 1:numView
    [~,marks]=litekmeans(data{iView}, 1000, 'MaxIter',5,'Replicates', 1);
    Anchor{iView} = marks;
    clear marks
end


%-------------save anchor
resultDir = '/home/tanpengjie1/Mazeqi/matlab/multi-view/large_scale_multi_view_ori/data_anchors/'
save([resultDir, 'Anchor_Kmean_', dataName, '.mat'], 'Anchor');