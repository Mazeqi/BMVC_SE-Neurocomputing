clear all;
addpath(genpath('./utils/'));
addpath(genpath('Bk_means/SH/'));
addpath(genpath('Bk_means/Bk_means/'));

%%必改
dataName = 'Hdigit';
algorithmName = 'BKmeans';

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

% %-------transform data ->(numInst, numFea)
% numView = length(data)
% for iView = 1:numView
%     data{iView} = data{iView}'; 
% end

data = X;
truth = Y;
clear X Y

numView = length(data);
numInst = size(data{1}, 1)
numClust = numel(unique(truth))

catData = 0;
for iV = 1:numView   
    if catData == 0
        catData = data{iV};
    else
        catData = cat(2, catData,  data{iV});
    end
end
size(catData)
[model, B, elapse] = SH_learn(catData, 16);
B = double(B);
B(B==0) = -1;


options.numClust = numClust;
options.numInst = numInst;
options.maxIters = 20;
options.truth = truth;
predLabels  = Bk_means(B, options);
resCluster = ClusteringMeasure(truth, predLabels);
fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
