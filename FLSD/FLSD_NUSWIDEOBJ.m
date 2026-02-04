clear all;
addpath(genpath('./utils/'));
addpath(genpath('FLSD/model/'));


dataName = 'NUSWIDEOBJ';
algorithmName = 'FLSD';

%%load data
%% omvc instance * features
dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);
data = X;
truth = Y;

numView = length(data);
numClust = length(unique(truth));
numInst  = length(truth); 

%% algorithm
lambda1  = 1e-1;
lambda2  = 1e-1;
neighbors = 7;
r = 3;

for iv = 1:numView
    data_iv = data{iv};
    data_iv = NormalizeFea(data_iv, 1);
    data{iv} = data_iv;

    % ------------- 构造缺失视角的索引矩阵 ----------- %
    W1 = eye(numInst);
    G{iv} = W1;   
end
    

%% ---------- nearest neighbor graph of feature construction ------------ %
for iv = 1:numView
    options = [];
    options.NeighborMode = 'KNN';
    options.k = neighbors;
    options.WeightMode = 'Binary';      % Binary  HeatKernel
    Z1 = full(constructW(data{iv}, options));
    W{iv} = (Z1+Z1')/2;
    clear Z1
end

opts.lambda1 = lambda1;
opts.lambda2 = lambda2;
opts.r       = r;
opts.nnClass = numClust;
opts.num_view= numView;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
opts.max_iter= 2;
[P] = GIMC_FLSD(data, W, G, opts);
    
P(isnan(P)) = 0;
P(isinf(P)) = 1e5;

new_F = P;
norm_mat = repmat(sqrt(sum(new_F.*new_F,2)),1,size(new_F,2));
    
% avoid divide by zero
for i = 1:size(norm_mat,1)
    if (norm_mat(i,1)==0)
        norm_mat(i,:) = 1;
    end
end
new_F = new_F./norm_mat; 

predLabels = litekmeans(real(new_F), numClust, 'Replicates',20);
resCluster = ClusteringMeasure(truth, predLabels);


fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n', resCluster(1), resCluster(2), resCluster(3), resCluster(4));



   
