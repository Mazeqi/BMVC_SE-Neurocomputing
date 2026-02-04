
%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('OMVC/model/'));

dataName = 'Hdigit';
algorithmName = 'OMVC'
neighbor = 7;

        
%%load data
%% omvc instance * features
dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);
data = X;
truth = Y;

numView = length(data);
numClust = length(unique(truth));
numInst  = length(truth); 

for iV = 1:numView
      data{iV}(data{iV}<0) = 0;
      data{iV} = data{iV}./sum(sum(data{iV}));
end

%% data processing
W = cell(numView, 1);
for iV = 1:numView
    W{iV} = diag(sparse(ones(numInst, 1)));
end

%% algorithm
option.label = truth;
option.k = numClust;
option.maxiter = 1;
option.tol = 1e-4;
option.num_cluster = numClust;
option.decay = 1;
option.alpha = 1e-3 * ones(numView,1);
option.beta = 1e-8 * ones(numView,1);
option.pass = 2;
option.loss = 0;
blockSize = 50;

percentDel = [0.1 0.3 0.5];
i_percent = 3;
ACC = zeros(1, 5);
NMI = zeros(1, 5);
Pur = zeros(1, 5);
Fscore = zeros(1, 5);

for f = 1:5
    datafolds = ['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'];
    load(datafolds);
    data_in = data;
    folds_del = folds{f};
    for iv = 1:numView
        data_iv = data_in{iv};
        ind_0 = find(folds_del(iv, :) == 0);
        ind_1 = find(folds_del(iv, :) == 1);
        exist_data = data_iv(ind_1, :);
        mean_exist_data = mean(exist_data, 1);
        data_iv(ind_0, :) = repmat(mean_exist_data, length(ind_0), 1);
        data_in{iv} = data_iv;
    end

    [U_total, V, U_star_total, Loss, pass] = ONMF_Multi_PGD_search(data_in, W, option, blockSize);
    predLabels = litekmeans(U_star_total{pass}, numClust, 'Replicates',20);
    resCluster = ClusteringMeasure(truth, predLabels);
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



   
