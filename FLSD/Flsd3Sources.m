%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('FLSD/model/'));

%%must to modify
percentDelList = [0.3];
dataName = '3sources3vbig';
algorithmName = 'FLSD'


%% read dataset
for iDper = 1:length(percentDelList)
    percentDel = percentDelList(iDper)
    dataFold = ['dataset/', dataName,'_percentDel_',num2str(percentDel),'.mat'];
    dataOrigin = ['dataset/', dataName, 'Rnsp.mat'];

    resultDir = [ 'Results/ResultTabels/',  dataName, '/', 'percentDel=', num2str(percentDel), '/',algorithmName, '/'];

    if(~exist(resultDir,'dir'))
        mkdir(resultDir);
    end
    
    %% set for flsd
    if iDper == 2
        lambda1  = 1e-1;
        lambda2  = 1e-2;
        neighbors = 7;
        r = 3;
    end
    
    if iDper == 1
        lambda1  = 1e-5;
        lambda2  = 1e-5;
         neighbors = 50;
          r = 2;
    end
    
    if iDper == 3
        lambda1  = 1e-5;
        lambda2  = 1e1;
        neighbors = 7;
        r = 2;
    end
        
    %% run
    numF = 5;
    ACC = zeros(1, numF);
    NMI = zeros(1, numF);
    Pur = zeros(1, numF);
    for f = 1:numF
        load(dataOrigin);
        load(dataFold);
        
        num_view = length(X)
        numClust = length(unique(truth))
        numInst  = length(truth)

        ind_folds = folds{f};
        
        for iv = 1:length(X)
            X1 = X{iv}';
            X1 = NormalizeFea(X1,1);
            ind_0 = find(ind_folds(:,iv) == 0);  % indexes of misssing instances
            
            X1(ind_0,:) = [];       % 去掉 缺失样本
            Y{iv} = X1;
            % ------------- 构造缺失视角的索引矩阵 ----------- %
            W1 = eye(numInst);
            W1(ind_0,:) = [];
            G{iv} = W1;                            
            Ind_ms{iv} = ind_0;
        end
        clear X X1 W1 ind_0
        X = Y;
        clear Y      

        %% ---------- nearest neighbor graph of feature construction ------------ %
        for iv = 1:length(X)
            options = [];
            options.NeighborMode = 'KNN';
            options.k = neighbors;
            options.WeightMode = 'Binary';      % Binary  HeatKernel
            Z1 = full(constructW(X{iv},options));
            W{iv} = (Z1+Z1')/2;
            clear Z1
        end

        opts.lambda1 = lambda1;
        opts.lambda2 = lambda2;
        opts.r       = r;
        opts.nnClass = numClust;
        opts.num_view= num_view;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        opts.max_iter= 50;
        [P] = GIMC_FLSD(X,W,G,opts);
        
        %P(isnan(P)) = 0;
        %P(isinf(P)) = 1e5;
        
        new_F = P;
        norm_mat = repmat(sqrt(sum(new_F.*new_F,2)),1,size(new_F,2));
        
        % avoid divide by zero
        for i = 1:size(norm_mat,1)
            if (norm_mat(i,1)==0)
                norm_mat(i,:) = 1;
            end
        end
        new_F = new_F./norm_mat; 

       kmeans_avg_iter = 10;
       resultKmeanList = zeros(kmeans_avg_iter, 3);
       fprintf('run kmeans...!')
       for iDk=1:kmeans_avg_iter
           rand('seed',iDk * 230);

%            MAXiter = 60; % Maximum number of iterations for KMeans 
%            REPlic = 60; % Number of replications for KMeans
%            preLabels = kmeans(real(new_F), numClust, 'maxiter',MAXiter,'replicates', REPlic,'Distance', 'sqeuclidean',...
%                     'EmptyAction','singleton');
             preLabels = litekmeans(real(new_F), numClust, 'Replicates',25);

           resultCurrentKmean = ClusteringMeasure(truth, preLabels);

           resultKmeanList(iDk, 1) = resultCurrentKmean(1);
           resultKmeanList(iDk, 2) = resultCurrentKmean(2);
           resultKmeanList(iDk, 3) = resultCurrentKmean(3);
       end
       resultKmean = mean(resultKmeanList, 1);

       ACC(f) = resultKmean(1) * 100
       NMI(f) = resultKmean(2) * 100
       Pur(f) = resultKmean(3) * 100
    end

    %% -------------------- select max nmi and save as [acc nmi pur stdAcc. stdNmi stdPur]
    meanACC = mean(ACC)
    meanNmi = mean(NMI)
    meanPur = mean(Pur)

    meanAccStd = std(ACC)
    meanNmiStd = std(NMI)
    meanPurStd = std(Pur)

    meanResult = [];    
    meanResult = [meanResult; meanACC meanNmi meanPur meanAccStd meanNmiStd meanPurStd];
%     save([resultDir, dataName,  '_meanNmi=', num2str(meanNmi),  '_percentDel=', num2str(percentDel), '_result.mat'], 'meanResult');
end