%This is  a  sample demo
%Test Digits dataset
clear all;
addpath(genpath('./utils/'));
addpath(genpath('MultiNMF/model/'));

%% parameter setting
options = [];
options.maxIter = 200;
options.error = 1e-2;
options.nRepeat = 50;
options.minIter = 50;
options.meanFitRatio = 0.01;
options.rounds = 60;

% options.kmeans means whether to run kmeans on v^* or not
% options alpha is an array of weights for different views
options.alpha = [0.01 0.01 0.01];
options.kmeans = 1;

%%必改
percentDelList = [0.1 0.3 0.5];
dataName = 'BDGP';
algorithmName = 'MultiNMF'

%% read dataset
for iDper = 1:length(percentDelList)
    percentDel = percentDelList(iDper)
    dataFold = ['dataset/', dataName,'_percentDel_',num2str(percentDel),'.mat'];
    dataOrigin = ['dataset/', dataName, '.mat'];

     resultDir = [ 'Results/ResultTabels/',  dataName, '/', 'percentDel=', num2str(percentDel), '/',algorithmName, '/'];
    if(~exist(resultDir,'file'))
        mkdir(resultDir);
    end

    %% run
    numF = 5;
    ACC = zeros(1, numF);
    NMI = zeros(1, numF);
    Pur = zeros(1, numF);
    for f = 1:numF
        load(dataOrigin);
        load(dataFold);
        
        %%load data
        data{1} = X{1}';
        data{2} = X{2}';
        data{3} = X{3}';
        clear X;
        
        truth = Y;
        clear Y;
        
        numView = length(data)
        numClust = length(unique(truth))
        numInst  = length(truth); 
        
        ind_folds = folds{f};
        truthF = truth;
        clear truth
        
        
        %% normalize data matrix
        for iV = 1:length(data)
            iView = data{iV}';
            
            ind_0 = find(ind_folds(:, iV) == 0); 
            ind_1 = find(ind_folds(:, iV) == 1);
            
            meanFill = mean(iView(ind_1, :), 1);
            
            for fid = 1:length(ind_0)
                iView(fid, :) = 0;
            end
            data{iV} = iView';
            
            data{iV} = data{iV} / sum(sum(data{iV}));
        end
 
        %run 
       [U_final, V_final, V_centroid log] = MultiNMF(data, numClust, truthF, options);

       kmeans_avg_iter = 10;
       resultKmeanList = zeros(kmeans_avg_iter, 3);
       for iDk=1:kmeans_avg_iter
           %preLabels = litekmeans(V_centroid, numClust, 'Replicates',20);

%            MAXiter = 60; % Maximum number of iterations for KMeans 
%            REPlic = 60; % Number of replications for KMeans
%            preLabels = kmeans(V_centroid, numClust, 'maxiter',MAXiter,'replicates', REPlic,'Distance', 'sqeuclidean',...
%                     'EmptyAction','singleton');
             preLabels = litekmeans(V_centroid, numClust, 'Replicates',25);

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

    %% -------------------- select max nmi and save as [acc nmi pur stdAcc. stdNmi purNmi]
    meanACC = mean(ACC)
    meanNmi = mean(NMI)
    meanPur = mean(Pur)

    meanAccStd = std(ACC)
    meanNmiStd = std(NMI)
    meanPurStd = std(Pur)

    meanResult = [];    
    meanResult = [meanResult; meanACC meanNmi meanPur meanAccStd meanNmiStd meanPurStd];
    save([resultDir, dataName,  '_meanNmi=', num2str(meanNmi),  '_percentDel=', num2str(percentDel), '_result.mat'], 'meanResult');
end