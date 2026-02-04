clear all;
addpath(genpath('./utils/'));
addpath(genpath('BMVC/model/'));

%%必改
dataName = 'Wiki_fea';
algorithmName = 'BMVC';

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
options.selIndex = 2;
options.beta=1e2;       % Hyper-para beta
options.gama=1e-3;         % Hyper-para gamma
options.lambda=0.00001;  % Hyper-para lambda
options.MaxIter = 50;
options.bR = 128;
percentDel = [0.1 0.3 0.5]
i_percent = 3

ACC = zeros(1, 5);
NMI = zeros(1, 5);
Pur = zeros(1, 5);
Fscore = zeros(1, 5);

for f = 1:5
    datafolds = ['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'];
    load(datafolds);
    folds_del = folds{f};
    data_in = data;
    for iv = 1:numView
        data_iv = data_in{iv};
        ind_0 = find(folds_del(iv, :) == 0);
        ind_1 = find(folds_del(iv, :) == 1);
        exist_data = data_iv(ind_1, :);
        mean_exist_data = mean(exist_data, 1);
        data_iv(ind_0, :) = repmat(mean_exist_data, length(ind_0), 1);
        data_in{iv} = data_iv;
    end
    anchor_path = ['data_anchors/Anchor_Incomplete/Anchor_Kmean_Incomplete_', dataName,'_', num2str(percentDel(i_percent)), '_', num2str(f), '.mat']
    load(anchor_path);
    [pred_label] =  BMVC(data_in, Anchor, truth, options);
    resCluster = ClusteringMeasure(truth, pred_label);
    ACC(f) = resCluster(1);
    NMI(f) = resCluster(2);
    Pur(f) = resCluster(3);
    Fscore(f) = resCluster(4);
end
meanAcc = mean(ACC);
meanNmi = mean(NMI);
meanPur = mean(Pur);
meanFScore = mean(Fscore);

fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n', meanAcc, meanNmi,meanPur, meanFScore);



