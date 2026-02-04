%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('MultiNMF/model/'));

dataName = '100Leaves';
algorithmName = 'MultiNMF'
dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);    

numView = length(data)
numClust = length(unique(truth))
numInst  = length(truth); 

%% normalize data matrix
for iV = 1:length(data)
    data{iV}(data{iV}<0) = 0;
    data{iV} = data{iV} ./ sum(sum(data{iV}));
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

%run data [nfea nSmp]
[U_final, V_final, V_centroid log] = MultiNMF(data, numClust, truth, options);

predLabels = litekmeans(V_centroid, numClust, 'Replicates',25);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));


       


   