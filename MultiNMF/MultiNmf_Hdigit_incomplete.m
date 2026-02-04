%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('MultiNMF/model/'));

dataName = 'Hdigit';
algorithmName = 'MultiNMF'
dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);    

%%load data
data = X;
clear X;

truth = Y;
clear Y;

numView = length(data)
numClust = length(unique(truth))
numInst  = length(truth); 

%% normalize data matrix
for iV = 1:length(data)
    data{iV}(data{iV}<0) = 0;
    data{iV} = data{iV} ./ sum(sum(data{iV}));
    data{iV} = data{iV}';
end

%% parameter setting
options = [];
options.maxIter = 200;
options.error = 1e-2;
options.nRepeat = 50;
options.minIter = 50;
options.meanFitRatio = 0.01;
options.rounds = 50;
options.alpha = 1e-1 * ones(numView,1);
options.kmeans = 1;

percentDel = [0.1 0.3 0.5];
i_percent = 2;
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

    %run data [nfea nSmp]
    [U_final, V_final, V_centroid log] = MultiNMF(data, numClust, truth, options);
    predLabels = litekmeans(V_centroid, numClust, 'Replicates',25);
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



   

       


   