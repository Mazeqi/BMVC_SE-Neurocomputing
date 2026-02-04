clear all;
addpath(genpath('./utils/'));
addpath(genpath('FLSD/model/'));


dataName = 'Hdigit';
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
lambda1  = 1e-3;
lambda2  = 1e-2;
neighbors = 7;
r = 3;

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
        data_iv = NormalizeFea(data_iv, 1);
        ind_0 = find(folds_del(iv, :) == 0);
        data_iv(ind_0,:) = [];
        data_in{iv} = data_iv;

        % ------------- 构造缺失视角的索引矩阵 ----------- %
        W1 = eye(numInst);
        W1(ind_0,:) = [];
        G{iv} = W1;   
    end
    

    %% ---------- nearest neighbor graph of feature construction ------------ %
    for iv = 1:numView
        options = [];
        options.NeighborMode = 'KNN';
        options.k = neighbors;
        options.WeightMode = 'Binary';      % Binary  HeatKernel
        Z1 = full(constructW(data_in{iv}, options));
        W{iv} = (Z1+Z1')/2;
        clear Z1
    end

    opts.lambda1 = lambda1;
    opts.lambda2 = lambda2;
    opts.r       = r;
    opts.nnClass = numClust;
    opts.num_view= numView;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    opts.max_iter= 30;
    [P] = GIMC_FLSD(data_in, W, G, opts);
        
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

%All view results: ACC = 0.5508 and NMI = 0.5559, Purity = 0.6209, Fscore = 0.4832


   
