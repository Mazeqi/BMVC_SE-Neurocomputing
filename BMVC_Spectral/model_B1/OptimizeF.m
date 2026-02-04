function [F] = OptimizeF(alpha, A, B, Q, F, options)

numView = length(A);
numInst = size(A{1}, 1);
lambda1 = options.lambda1;
lambda2 = options.lambda2;
maxNgIters = options.maxNgIters;

for iter = 1:maxNgIters
    
    sumA = 0;
    for iView = 1:numView
        sumA = sumA + alpha(iView)*A{iView};
    end
    
    sumB = lambda1*B'*Q;
    if options.maxNgIters == 1 
        F = (1./(lambda2*sumA))*sumB;
    else
        M = 2*lambda2*sumA*F + 2*sumB;
        M(isnan(M)) = 0;
        [U,S,V] = svd(M,"econ");
        F = sqrt(numInst)*U*V';  
    end
    
    
end

end
