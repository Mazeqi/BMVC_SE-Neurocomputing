function [pred_label] = MLAN(X, truth, options)
%------------------Initial Parameter-----------------%
numView  = options.numView;
numInst  = options.numInst;
numClust = options.numClust;
lambda   = options.lambda;
k = options.k;
maxIter = options.maxIter;
%-------------------Initial Wv------------------------%
Wv = ones(numView,1) / numView;

%---------------------Initial S---------------------%
% X:numInst * fea
sumDView = 0;
dV = cell(1, numView);
for iView = 1:numView
    xView = X{iView};
    sumX = sum(xView.^2, 2);
    dView = bsxfun(@plus, sumX, bsxfun(@plus, sumX, -2 * (xView*xView')));
    sumDView = sumDView + Wv(iView)*dView;
end
clear xView sumX dView 
%----------------initial alpha-----------------------%
distDF = sumDView;
sortDistDf = sort(distDF, 2);
rr = zeros(numInst,1);
for i = 1:numInst
    di = sortDistDf(i, 2:k+2);
    rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
end
clear distDF sortDistDf di
alpha = mean(rr);
clear rr
%-------------------------initial S---------------------%
S = -0.5/alpha*sumDView;
clear sumDView
S = S - diag(diag(S));
for is = 1:size(S,1)
    ind = [1:size(S,1)];
    ind(is) = [];
    % different i is independent
    S(is,ind) = EProjSimplex_new(S(is,ind));
end
clear ind

for iter = 1:maxIter
    tic;
    %--------------------update Wv--------------------%
    sumDView = 0;
    for iView = 1:numView
        
        xView = X{iView};
        sumX = sum(xView.^2, 2);
        dView = bsxfun(@plus, sumX, bsxfun(@plus, sumX, -2 * (xView*xView')));
        
        sumSd = dView.*S;
        Wv(iView) = 0.5 ./ sqrt(sum(sum(sumSd)+eps));
        sumDView = sumDView + Wv(iView)* dView;
    end
    clear sumSd dView sumX xView
    

    
    %-------------------update F----------------------%
    LS = (S+S')/2;
    LS = diag(sum(LS)) - LS;
    clear S 
    [F, ~, ev] = eig1(LS, numClust, 0);
    clear LS
    
    sumF = sum(F.^2, 2);
    dF = bsxfun(@plus, sumF, bsxfun(@plus, sumF, -2 * (F*F')));
    distDF = sumDView + lambda*dF;
    clear sumDView dF sumF 

%     %----------------update alpha-----------------------%
%     
%     sortDistDf = sort(distDF, 1);
%     rr = zeros(numInst,1);
%     for i = 1:numInst
%         di = sortDistDf(i, 2:k+2);
%         rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
%     end
%     alpha = mean(rr)
    
    %-------------------update S----------------------%
    S = -0.5/alpha*(distDF);
    S = S - diag(diag(S));
    clear distDF
    
    for is = 1:size(S,1)
        ind = [1:size(S,1)];
        ind(is) = [];
        % different i is independent
        S(is,ind) = EProjSimplex_new(S(is,ind));
    end
    clear ind
    
    %-----------------convergence---------------------------------%
%     sumSd = 0;
%     for iView = 1:numView
%         xView = X{iView};
%         sumX = sum(xView.^2, 2);
%         dView = bsxfun(@plus, sumX, bsxfun(@plus, sumX, -2 * (xView*xView')));
%         sumSd = sumSd + Wv(iView)*dView.*S;
%     end
%     clear dView sumX xView
    
    %obj = sum(sumSd(:)) + alpha*trace(S'*S) + 2 * lambda*trace(F'*LS*F);
%     clear sumSd
    [~, iterLabel] = max(F, [], 2);
    resCluster = ClusteringMeasure(truth, iterLabel);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f,  Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
    clear resCluster iterLabel
    toc;
    disp(['运行时间: ',num2str(toc)]);
end
disp('----------Main Iteration Completed----------');
[~,pred_label] = max(F,[],2);