function [pred_label] = BMVC(X, Anchor, truth, options)

numView  = options.numView;
numInst  =  options.numInst;
numClust =  options.numClust;
selIndex = options.selIndex;
%------------Initializing parameters--------------
MaxIter = options.MaxIter;       % 5 iterations are okay, but better results for 10
innerMax = 10;
r = 5;              % r is the power of alpha_i
L = options.bR;            % Hashing code length
% beta = 0.003;       % Hyper-para beta
% gamma = .01;        % Hyper-para gamma
% lambda = 0.00001;   % Hyper-para lambda
beta = options.beta;       % Hyper-para beta
gamma = options.gama;        % Hyper-para gamma
lambda = options.lambda;   % Hyper-para lambda

%----------这里会从(numInst, numFea)转成 (numFea, numInst)
for it = 1:numView
    %fprintf('The %d-th view numInstonlinear Anchor Embeeding...\n',it);
    dist = EuDist2(X{it}, Anchor{it}, 0);
    sigma = mean(min(dist,[],2).^0.5)*2;
    feaVec = exp(-dist/(2*sigma*sigma));
    X{it} = bsxfun(@minus, feaVec', mean(feaVec',2));% Centered data 
end

%----------这里的初始值调整会影响结果------------%
rand('seed',100);
sel_sample = X{selIndex}(:,randsample(numInst, 1000),:);
[pcaW, ~] = eigs(cov(sel_sample'), L);
B = sign(pcaW'*X{selIndex});
%size(B)
alpha = ones(numView,1) / numView;
U = cell(1,numView);

rand('seed',500);
C = B(:,randsample(numInst, numClust));
HamDist = 0.5*(L - B'*C);
[~,ind] = min(HamDist,[],2);
G = sparse(ind,1:numInst, 1, numClust, numInst, numInst);
G = full(G);
CG = C*G;

XXT = cell(1,numView);
for view = 1:numView
    XXT{view} = X{view}*X{view}';
end
clear HamDist ind initInd n_randm pcaW sel_sample view
%------------End Initialization--------------

disp('----------The proposed method (multi-view)----------');
for iter = 1:MaxIter
    tic;
    fprintf('The %d-th iteration...\n',iter);
    %---------Update Ui--------------
    alpha_r = alpha.^r;
    UX = zeros(L, numInst);
    for v = 1:numView
        U{v} = B*X{v}'/((1-gamma)*XXT{v}+beta*eye(size(X{v},1)));
        UX   = UX+alpha_r(v)*U{v}*X{v};
    end
    
    %---------Update B--------------
    B = sign(UX+lambda*CG);B(B==0) = -1;
    % clear UX CG
    
    %---------Update C and G--------------
    for iterInner = 1:innerMax
        % For simplicity, directly using DPLM here
        C = sign(B*G'); C(C==0) = 1;
        rho = .001; mu = .01; % Preferred for this dataset
        for iterIn = 1:3
            grad = -B*G' + rho*repmat(sum(C),L,1);
            C    = sign(C-1/mu*grad); C(C==0) = 1;
        end
        HamDist = 0.5*(L - B'*C); % Hamming distance referring to "Supervised Hashing with Kernels"
        [~,indx] = min(HamDist,[],2);
        G = sparse(indx,1:numInst,1,numClust,numInst,numInst);
    end
    CG = C*G;
    % clear iterIn grad HamDist indx mu rho
    
    %---------Update alpha--------------
    h = zeros(numView,1);
    sumH = 0;
    for view = 1:numView
        h(view) = norm(B-U{view}*X{view},'fro')^2 -gamma*norm(U{view}*X{view},'fro')^2 + beta*norm(U{view},'fro')^2;
        sumH = sumH + h(view);
    end
    H = bsxfun(@power,h, 1/(1-r));     % h = h.^(1/(1-r));
    alpha = bsxfun(@rdivide,H,sum(H)); % alpha = H./sum(H);
    % clear H h
     [~, iterLabel] = max(G,[],1);
    resCluster = ClusteringMeasure(truth, iterLabel);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
    toc;
     disp(['运行时间: ',num2str(toc)]);
end
disp('----------Main Iteration Completed----------');
[~,pred_label] = max(G,[],1);
end