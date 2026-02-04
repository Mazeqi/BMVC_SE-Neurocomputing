function [predLabels] = HSIC(X, Anchor, options)

numView  = options.numView;
numInst  =  options.numInst;
numClust =  options.numClust;
selIndex = options.selIndex;
truth = options.truth;
%------------Initializing parameters--------------
MaxIter = options.maxIters;
innerMax = 10;
r = 5;            % r is the power of alpha_i
L = options.bR;          % Hashing code length
% beta = .01;       % Hyper-para beta
% gamma = .001;     % Hyper-para gamma
% lambda = 0.00001; % Hyper-para lambda
beta = options.beta;       % Hyper-para beta
gamma = options.gamma;     % Hyper-para gamma
lambda = options.lambda; % Hyper-para lambda
rate  = 0.2;

%----------这里会从(numInst, numFea)转成 (numFea, numInst)
for it = 1:numView
    %fprintf('The %d-th view numInstonlinear Anchor Embeeding...\n',it);
    dist = EuDist2(X{it}, Anchor{it}, 0);
    sigma = mean(min(dist,[],2).^0.5)*2;
    feaVec = exp(-dist/(2*sigma*sigma));
    X{it} = bsxfun(@minus, feaVec', mean(feaVec',2));% Centered data 
end

dim = size(X{1}, 1);

%------------Parameter Initialization--------------
rand('seed',250);
r_sample = X{selIndex}(:,randsample(numInst, 500),:);
[pcaW, ~] = eigs(cov(r_sample'), L);
B = sign(pcaW'*X{selIndex});% B = sign(randn(L,numInst));

alpha = ones(numView,1) / numView;
W = cell(1,numView);

rand('seed',200);
C = B(:,randsample(numInst, numClust));
HamDist = 0.5*(L - B'*C);
[~,ind] = min(HamDist,[],2);
G = sparse(ind,1:numInst,1,numClust,numInst,numInst);
G = full(G);
CG = C*G;

XXT = cell(1,numView);
for view = 1:numView
    XXT{view} = X{view}*X{view}';
end
D = sparse(diag(ones(L, 1))); % L2 norm version

disp('----------The proposed method (multi-view)----------');
for iter = 1:MaxIter
    tic;
    fprintf('The %d-th iteration...\n',iter);
    %---------Seperate Bs and Bi--------------
    Bs = B(1:ceil(rate*L),:);
    Bi = B(ceil(rate*L)+1:end,:);
    
    %---------Update W--------------
    alpha_r = alpha.^r;
    WTX = zeros(L,numInst); 
    Wi = cell(1,numView);
    
    A = zeros(dim);
    T = zeros(dim,numInst);
    for v = 1:numView
        A = A + (1-gamma)*alpha_r(v)*XXT{v};
        T = T + alpha_r(v)*X{view};
    end
    
    Ws = (A+beta*eye(dim))\(T*Bs');
    
    for v = 1:numView
        Wi{v} = ((1-gamma)*XXT{v}+beta*eye(dim))\(X{v}*Bi');
        W{v} = [Wi{v} Ws];
        WTX  = WTX+alpha_r(v)*W{v}'*X{v};
    end

    %---------Update B--------------
    B = sign(WTX+lambda*CG);B(B==0) = -1;
    
    %---------Update C and G--------------
    for time = 1:innerMax
        DB = D*B; %C = ones(L,numClust); 
        % C(DB*G'<0) = -1;
        rho = 1e-3; mu = .2;
        for iter_num = 1:3
            grad = -DB*G'+ rho*repmat(sum(C),L,1);
            C = sign(C - 1/mu*grad);
        end

        HamDist = 0.5*(L - DB'*C);
        [~,indx] = min(HamDist,[],2);
        G = sparse(indx,1:numInst,1,numClust,numInst,numInst);
        
        CG = C*G;
        E = B - CG;
        Ei2 = sqrt(sum(E.*E, 2) + eps);
        D = sparse(diag(0.5./Ei2));
    end
    %---------Update alpha--------------
    h = zeros(numView,1);
    for view = 1:numView
        h(view) = norm(B-W{view}'*X{view},'fro')^2 + beta*norm(W{view},'fro')^2-gamma*norm(W{view}'*X{view},'fro');
    end
    H = bsxfun(@power,h, 1/(1-r));
    alpha = bsxfun(@rdivide,H,sum(H));
    [~,predLabels] = max(G,[],1);
    resCluster = ClusteringMeasure(truth, predLabels);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
    toc;
    disp(['运行时间: ',num2str(toc)]);
end
disp('----------Main Iteration Completed----------');
[~,predLabels] = max(G,[],1);
end