
%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('OMVC/model/'));

dataName = 'CCV';
algorithmName = 'OMVC'
neighbor = 7;

        
%%load data
%% omvc instance * features
dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

% %-------transform data ->(numInst, numFea)
numView = length(data)
for iView = 1:numView
    data{iView} = data{iView}'; 
end

truth = truelabel{1};
clear truelabel

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
option.alpha = 1e-2 * ones(numView,1);
option.beta = 1e-7 * ones(numView,1);
option.pass = 2;
option.loss = 0;
blockSize = 50;
[U_total, V, U_star_total, Loss, pass] = ONMF_Multi_PGD_search(data, W, option, blockSize);
predLabels = litekmeans(U_star_total{pass}, numClust, 'Replicates',20);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));



   
