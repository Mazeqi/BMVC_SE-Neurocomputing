function [predLabels] = Bk_means(B, options)
%   This is a wrapper function of ITQ learning.
%
%	      B: Rows of vectors of data points. Each row is sample point
numClust = options.numClust;
numInst = options.numInst;
maxIters = options.maxIters;
truth = options.truth;
rand('seed',666);
centers = B(randperm(numInst, numClust), :);

predLabels = zeros(numInst, 1);
for iter = 1:maxIters
    for iSmp = 1:numInst
        minHamin = 1e30;
        curIndex = -1;
        for iCen = 1:numClust
            %curHam = hammingDist(B(iSmp,:), centers(iCen, :));
            curHam = pdist2(B(iSmp,:), centers(iCen, :),'hamming');
            if minHamin > curHam
                curIndex = iCen;
                minHamin = curHam;
            end
        end
        predLabels(iSmp) = curIndex; 
    end
    
    for iCen = 1:numClust
        numPerCen  = 0;
        curCen = 0;
        
        for iSmp = 1:numInst
            if predLabels(iSmp, 1) == iCen
                numPerCen = numPerCen + 1;
                curCen = curCen + B(iSmp, :);
            end
        end 
        
        if numPerCen == 0
            rand('seed',666);
            centers(iCen,:) = B(randperm(numInst, 1), :);
        else
            centers(iCen,:) = curCen / numPerCen;
        end 
        
    end
    
    centers = sign(centers);
    %size(centers)
    centers(centers == 0) = -1;
    resCluster = ClusteringMeasure(truth, predLabels);
    fprintf('All view results: ACC = %.4f and NMI = %.4f, Purity = %.4f, Fscore = %.4f\n\n',resCluster(1),resCluster(2),resCluster(3), resCluster(4));
end
