function [pred_label, B] = BmvcSpectral(X, Anchor, truth, options)

numView  = options.numView;
numInst  =  options.numInst;
numClust =  options.numClust;
%------------Initializing parameters--------------%
if (~isfield(options, 'bR'))
   bR = 128;
else
   bR = options.bR;
end 
%lambda0 = options.lambda0;
%論文中的lam1 和 lam2和代碼中相反
lambda1 = options.lambda1;
lambda2 = options.lambda2;
lambda3 = options.lambda3;
if (~isfield(options, 'maxNgIters'))
   options.maxNgIters = 8;
end

maxIters = options.maxIters;
innerMaxIters = 10;

if (~isfield(options, 'r'))
   r=5;
else
    r = options.r;
end           % r is the power of alpha_i
%----------这里会从(numInst, numFea)转成 (numFea, numInst)
LvA = cell(1, numView);
XXT = cell(1, numView);

for iView = 1:numView
    %fprintf('The %d-th view numInstonlinear Anchor Embeeding...\n',it);
    dist = EuDist2(X{iView}, Anchor{iView}, 0);
    sigma = mean(min(dist,[],2).^0.5)*2;
    Zv = exp(-dist/(2*sigma*sigma));
    X{iView} = bsxfun(@minus, Zv', mean(Zv',2));% Centered data 
    clear dist sigma 
    
%     %---------------initial spectral matrix------------%
    ZvT = Zv';
    invA = diag((full(sum(ZvT, 2))).^(-1/2));
    ZvA = Zv*invA;
    LvA{iView} = eye(size(ZvA, 1)) - ZvA*ZvA';
    clear invA ZvA Zv

%     optsW.NeighborMode = 'KNN';
%     optsW.k = 100;
%     optsW.WeightMode = 'Binary';      % Binary  HeatKernel
% 
%     Z1 = full(constructW(X{iView}', optsW));
%     Z1 = (Z1+Z1')/2;
%     LvA{iView} = diag(sum(Z1,2))-Z1;
%     clear Z1;
    XXT{iView} = X{iView}*X{iView}';

end

% %---------------------------initial alpha----------------------------%
alpha = ones(numView,1) / numView;

%--------------------initial W-------------------------%
% sumWx = 0;
%  W = cell(1,numView);
% for iView = 1:numView
%    rand('seed',iView*100);
%    randW = rand(bR, size(X{iView}, 1));  
%    if size(X{iView}, 1) < bR
%        W{iView} = orth(randW);
%    else
%        W{iView} = (orth(randW'))';
%    end
% %    sumWx = sumWx + 1/numView*W{iView}*X{iView};
% end

% %------------------------------initial B--------------------------------%
% B = sign(sumWx);
%--------NUSWIDEOBJ 300
%--------normal 100
%----------others rand('seed', 999);
selIndex = options.selIndex;
rand('seed', 999);

selSample = X{selIndex}(:, randsample(numInst, 1000), :);
%selSample = fillmissing(selSample, 'previous');

[pcaW, ~] = eigs(cov(selSample'), bR);
B = sign(pcaW'*X{selIndex});


% %---------------------------initial F--------------------------------%
%--------NUSWIDEOBJ 200
%--------normal 100
rand('seed', 100);
F = rand(numInst, numClust);
F = orth(F);

%---------------------------initial C G--------------------------------%
rand('seed', 999);
C = B(:, randsample(numInst, numClust));
hamDist = 0.5*(bR - B'*C);
[~,ind] = min(hamDist,[],2);
clear hamDist 
%sparse最重要是前面三个参数, ind存的是 numInst中每一个的label, 因此前两个参数的长度要一致，第三个参数是填入的值
%第四第五是生成矩阵的长度
G = sparse(ind, 1:numInst, 1, numClust, numInst, numInst);
G = full(G);

%--------------------initial Q-------------------------%
%rand('seed',666);
randQ = rand(bR, numClust);  
if numClust < bR
      Q = orth(randQ);
else
      Q = (orth(randQ'))';
end

F = OptimizeF(alpha, LvA, B, Q, F, options);
for iter = 1:maxIters
    tic;
    fprintf('The %d-th iteration...\n',iter);
    
    alpha_r = alpha.^r;
    sumWx = 0;
    for iView = 1:numView
        %-------------------update Wv -------------------%
%         tempW = B*X{iView}';
%         [Lw, ~, Rw] = svd(tempW, 'econ');
%         W{iView} = Lw*Rw';
        %W{iView} = B*X{iView}'/((1-0.01)*X{iView}*X{iView}'+0.03*eye(size(X{iView}, 1)));
        %W{iView} = B*X{iView}'/((1-lambda0)*X{iView}*X{iView}');
       % XXT{iView} = min(XXT{iView}, 100);
        %XXT{iView} = max(XXT{iView}, -100);

        W{iView} = B*X{iView}'/XXT{iView};
        
        W{iView} = min(W{iView}, 10);
        W{iView} = max(W{iView}, -10);
        
        sumWx = sumWx + alpha_r(iView)*W{iView}*X{iView};
    end
    
    %-------------------update B -------------------%
    sgnB = sumWx + lambda1*Q*F'+lambda3*C*G;
    %sgnB = sumWx+lambda3*C*G;
    B = sign(sgnB);
    B(B==0) = -1;
        
%     %-------------------update Q -------------------%
    tempQ = B*F;
    tempQ(isnan(tempQ)) = 0;
    [Lq, ~, Rq] = svd(tempQ, 'econ');
    Q = Lq*Rq';
%     
    %-------------------update GC -------------------%
    %preFc = 0;
    %nowFc = 0;
    for iterInner = 1:innerMaxIters
        C = sign(B*G');
        C(C == 0) = 1;
        rho = .001; mu=.01;
        for iterIn = 1:3
            grad = -B*G' + rho*repmat(sum(C, 1), bR, 1);
            C = sign(C - 1/mu*grad);
            C(C==0)=1;
        end
%         
%         if nowFc == 0 && preFc == 0
%             nowFc = norm(B-C*G,'fro')^2;
%             preFc = nowFc;
%         else
%             preFc = nowFc;
%             nowFc = norm(B-C*G,'fro')^2;
%         end
%         
%         if nowFc <= preFc
%             mu = 0.5*mu;
%         else
%             mu = 1.2*mu;
%         end
%            
%         mu = min(mu, 0.2);
%         mu = max(mu, 0.1);
        
        hamDist = 0.5*(bR - B'*C);
        [~,ind] = min(hamDist,[],2);
        G = sparse(ind, 1:numInst, 1, numClust, numInst, numInst);
        G = full(G);
    end

    %-------------------update F -------------------%
    F = OptimizeF(alpha_r, LvA, B, Q, F, options);
    
    %---------Update alpha--------------
    h = zeros(numView,1);
    for iView = 1:numView
        h(iView) = norm(B-W{iView}*X{iView},'fro')^2 - lambda0*norm(W{iView}*X{iView},'fro')^2 + lambda1*norm(B - Q*F','fro')^2 + lambda2*trace(F'*LvA{iView}*F);
    end
    H = bsxfun(@power, h, 1/(1-r));     % h = h.^(1/(1-r));
    alpha = bsxfun(@rdivide,H,sum(H)); % alpha = H./sum(H);
    
    [~, iterLabel] = max(G,[],1);
    resCluster = ClusteringMeasure(truth, iterLabel);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
    toc;
    disp(['运行时间: ',num2str(toc)]);
end
disp('----------Main Iteration Completed----------');
[~,pred_label] = max(G,[],1);
end