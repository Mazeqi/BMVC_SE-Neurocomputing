clear all;
addpath(genpath('./utils/'));
addpath(genpath('LMSC/model/'));

%%必改
dataName = '100Leaves';
algorithmName = 'LMSC';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);
numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

options.lambda = 1e-5; 
options.K = 100; 
options.maxIters = 20;
latentFea  = LRMSC(data, options);
[predLabels] = SpectralClustering(latentFea,numClust);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
