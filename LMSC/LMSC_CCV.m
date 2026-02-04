clear all;
addpath(genpath('./utils/'));
addpath(genpath('LMSC/model/'));

%%必改
dataName = 'CCV';
algorithmName = 'LMSC';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

truth = truelabel{1};
clear truelabel

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

% %---------> numFea numInst
% for iV = 1:numView   
%     data{iV} = data{iV}';
% end

options.lambda = 10; 
options.K = 100; 
options.maxIters = 2;
latentFea  = LRMSC(data, options);
[predLabels] = SpectralClustering(latentFea,numClust);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
