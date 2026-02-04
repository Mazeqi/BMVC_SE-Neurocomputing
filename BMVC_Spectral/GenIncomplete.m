clear;
clc

dataName = 'Wiki';
numViews = 2;
numInst = 2866;

percentDel = [0.1 0.3 0.5]

for i_percent = 1:length(percentDel)

    folds = {};
    for f = 1:20
        foldResults = ones(numInst, numViews);
        for iV = 1:numViews
            instanceIdx = randperm(numInst);
            numDelInst = floor(numInst*percentDel(i_percent));
            if iV ~= numViews
                foldResults(instanceIdx(1:numDelInst), iV) = 0;
            else
                numCurDel = 0;

                for i_Inst = 1:numInst

                    inst = instanceIdx(i_Inst);
                    tag_can_del = 0;

                    for i_pre_v = 1:numViews
                        tag_can_del = tag_can_del + foldResults(inst, i_pre_v);
                    end

                    if tag_can_del > 1
                        foldResults(inst, numViews) = 0;
                        numCurDel = numCurDel + 1;
                    end

                    if numCurDel == numDelInst
                        break;
                    end
                end
            end
        end
        folds{f} = foldResults;
    end

    if ~exist(['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'], 'file')
        save(['Incomplete_Ex/', dataName,'_percentDel_', num2str(percentDel(i_percent)), '.mat'], 'folds');
    else
        fprintf("the file exist\n");
    end
end
