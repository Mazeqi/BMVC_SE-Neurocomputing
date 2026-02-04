%% LMSC (CVPR-17)
load('ORL_mtv.mat');
fprintf('Latent representation multiview subspace clustering\n');
num_views = size(X,2);
numClust = size(unique(gt),1);

lambda = 0.1; K = 100; 
[nmi,ACC,f,RI,H] = LRMSC(X,gt,numClust,lambda,K);
