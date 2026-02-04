
%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('OMVC/model/'));

%%必改
percentDelList = [0.1];
dataName = 'BDGP';
algorithmName = 'OMVC'
neighbor = 7;


%% read dataset
for iDper = 1:length(percentDelList)
    percentDel = percentDelList(iDper)
    dataFold = ['dataset/', dataName,'_percentDel_',num2str(percentDel),'.mat'];
    dataOrigin = ['dataset/', dataName, '.mat'];

    resultDir = [ 'Results/ResultTabels/',  dataName, '/', 'percentDel=', num2str(percentDel), '/',algorithmName, '/'];
    if(~exist(resultDir,'file'))
        mkdir(resultDir);
    end
    
    numF = 5;
    ACC = zeros(1, numF);
    NMI = zeros(1, numF);
    Pur = zeros(1, numF);
    %% run
    for f = 1:numF
        load(dataOrigin);
        load(dataFold);
        
        %%load data
        %% omvc instance * features
        data{1} = X{1};
        data{2} = X{2};
        data{3} = X{3};
        clear X;
        
        truth = Y;
        clear Y;
        
        numView = length(data);
        numClust = length(unique(truth));
        numInst  = length(truth); 
        
        %%load truth
        ind_folds = folds{f};
        truthF = truth;
        clear truth
        
        for iV = 1:numView
            ind_0 = find(ind_folds(:, iV) == 0);
            for j = 1:numel(ind_0)
                
                curTotalIndex = 1:ind_0(j);
                total = sum(data{iV}(curTotalIndex, :),1);
                incomplete = sum(data{iV}(ind_0(1:j),:),1);
                
                curTotalLength = length(curTotalIndex) - length(ind_0(1:j)) + 0.0000000000000001;
                data{iV}(ind_0(j),:) = (total - incomplete)./(curTotalLength);
            end
        end
        
        for iV = 1:numView
              data{iV}(data{iV}<0) = 0;
            data{iV} = data{iV}./sum(sum(data{iV}));
        end

        
        %% data processing
        W = cell(numView, 1);
        
        for iV = 1:numView
            W{iV} = diag(sparse(ones(numInst, 1)));
            counter = 0;
            ind_0 = find(ind_folds(:, iV) == 0);
            for j = 1:numel(ind_0)
                %counter = counter +1;
                counter = ind_0(j) - length(ind_0(1:j));
                W{iV}(ind_0(j),ind_0(j)) = 1.0*counter/ind_0(j);
            end
        end
        
 
        %% algorithm
        option.label = truthF;
        option.k = numClust;
        option.maxiter = 200;
        option.tol = 1e-4;
        option.num_cluster = numClust;
        option.decay = 1;
        option.alpha = 1e1 * ones(numView,1);
        option.beta = 1e-7 * ones(numView,1);
        option.pass = 2;
        option.loss = 0;
        blockSize = 50;
        [U_total, V, U_star_total, Loss, pass] = ONMF_Multi_PGD_search(data, W, option, blockSize);
    
       kmeans_avg_iter = 20;
       resultKmeanList = zeros(kmeans_avg_iter, 3);
       
       fprintf("run kmeans...\n");
       for iDk=1:kmeans_avg_iter
           rand('seed',230);

%            MAXiter = 60; % Maximum number of iterations for KMeans 
%            REPlic = 50; % Number of replications for KMeans
%            preLabels = kmeans(U_star_total{pass}, numClust, 'maxiter',MAXiter,'replicates', REPlic,'Distance', 'sqeuclidean',...
%                    'EmptyAction','singleton');
            preLabels = litekmeans(U_star_total{pass}, numClust, 'Replicates',20);

           resultCurrentKmean = ClusteringMeasure(truthF, preLabels);

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
    %save([resultDir, dataName,  '_meanNmi=', num2str(meanNmi),  '_percentDel=', num2str(percentDel), '_result.mat'], 'meanResult');
end