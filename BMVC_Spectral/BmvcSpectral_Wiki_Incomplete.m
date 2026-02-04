clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC_Spectral/model_B1/'));

%%必改
dataName = 'Wiki_fea';
algorithmName = 'BmvcSpectral';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

data = X;
truth = Y;
clear X Y

numView = length(data)
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.numView = numView;
options.numInst = numInst;
options.numClust = numClust;

%1e2 1e2
options.lambda1 = 6e2;
options.lambda2 = 6e2;
options.lambda3 = 1e-5;
options.maxIters = 50;
options.selIndex = 1;
options.bR = 96;
options.r = 5;
options.maxNgIters = 8;
percentDel = [0.1 0.3 0.5]
i_percent = 2
f = 1

datafolds = ['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'];
load(datafolds);

anchor_path = ['data_anchors/Anchor_Incomplete/Anchor_Kmean_Incomplete_', dataName,'_', num2str(percentDel(i_percent)), '_', num2str(f), '.mat']
load(anchor_path);
folds_del = folds{f};
for iv = 1:numView
    data_iv = data{iv};
    ind_0 = find(folds_del(iv, :) == 0);
    ind_1 = find(folds_del(iv, :) == 1);
    exist_data = data_iv(ind_1, :);
    mean_exist_data = mean(exist_data, 1);
    data_iv(ind_0, :) = repmat(mean_exist_data, length(ind_0), 1);
    data{iv} = data_iv;
end
[pred_label, resultB] = BmvcSpectral(data, Anchor, truth, options);


