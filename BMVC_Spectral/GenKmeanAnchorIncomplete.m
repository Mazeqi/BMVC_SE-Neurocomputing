clear;  clear memory; clc;
addpath(genpath('./utils/'));

% NUSWIDEOBJ Caltech101 Wiki_fea Caltech256 Caltech101-20 cifar10
dataName = 'Wiki_fea'
percentDel = [0.1 0.3 0.5]

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin)

data = X;
%truth = truelabel{1};
truth = Y;
% clear X Y

%----------------------Caltech101 NUSWIDEOBJ--------------------%
numView = length(data)
numInst = length(truth)

%-------------gen anchor---------------%
if size(data{1}, 1) < size(data{1}, 2)
    for iView = 1:numView
        data{iView} = data{iView}';
    end
end
    
for i_percent = 1:length(percentDel)
    datafolds = ['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'];
    load(datafolds);
    for f = 1:5
        folds_del = folds{f}';
        Anchor = cell(numView, 1);
        
        for iv = 1:numView
            data_iv = data{iv};
            ind_0 = find(folds_del(iv, :) == 0);
            ind_1 = find(folds_del(iv, :) == 1);
            exist_data = data_iv(ind_1, :);
            mean_exist_data = mean(exist_data, 1);

            data_iv(ind_0, :) = repmat(mean_exist_data, length(ind_0), 1);

            [~,marks]=litekmeans(data_iv, 1000, 'MaxIter', 5,'Replicates', 1);
            Anchor{iv} = marks;
            clear marks
        end
        save(['data_anchors/Anchor_Incomplete/Anchor_Kmean_Incomplete_', dataName,'_', num2str(percentDel(i_percent)), '_', num2str(f), '.mat'], 'Anchor');
    end
end
