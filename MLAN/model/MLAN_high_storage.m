function [pred_label] = MLAN_high_storage(X, truth, options)
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
    dV{iView} = dView;
    sumDView = sumDView + Wv(iView)*dView;
end

%----------------initial alpha-----------------------%
distDF = sumDView;
sortDistDf = sort(distDF, 2);
rr = zeros(numInst,1);
for i = 1:numInst
    di = sortDistDf(i, 2:k+2);
    rr(i) = 0.5*(k*di(k+1)-sum(di(1:k)));
end
alpha = mean(rr);

%-------------------------initial S---------------------%
S = -0.5/alpha*sumDView;
S = S - diag(diag(S));
for is = 1:size(S,1)
    ind = [1:size(S,1)];
    ind(is) = [];
    % different i is independent
    S(is,ind) = EProjSimplex_new(S(is,ind));
end


for iter = 1:maxIter
    tic;
    %--------------------update Wv--------------------%
    sumDView = 0;
    for iView = 1:numView
        sumSd = dV{iView}.*S;
        Wv(iView) = 0.5 ./ sqrt(sum(sum(sumSd)+eps));
        sumDView = sumDView + Wv(iView)* dV{iView};
    end
    
    %-------------------update F----------------------%
    LS = (S+S')/2;
    LS = diag(sum(LS)) - LS;
    [F, ~, ev] = eig1(LS, numClust, 0);
    sumF = sum(F.^2, 2);
    dF = bsxfun(@plus, sumF, bsxfun(@plus, sumF, -2 * (F*F')));
    distDF = sumDView + lambda*dF;
    
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
    
    for is = 1:size(S,1)
        ind = [1:size(S,1)];
        ind(is) = [];
        % different i is independent
        S(is,ind) = EProjSimplex_new(S(is,ind));
    end
    
    %-----------------convergence---------------------------------%
    sumSd = 0;
    for iView = 1:numView
        sumSd = sumSd + Wv(iView)*dV{iView}.*S;
    end
    
    obj = sum(sumSd(:)) + alpha*trace(S'*S) + 2 * lambda*trace(F'*LS*F);
    [~, iterLabel] = max(F, [], 2);
    resCluster = ClusteringMeasure(truth, iterLabel);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f,  Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
    toc;
    disp(['运行时间: ',num2str(toc)]);
end
disp('----------Main Iteration Completed----------');
[~,pred_label] = max(F,[],2);