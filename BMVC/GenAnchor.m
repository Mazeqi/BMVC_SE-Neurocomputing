clear;  clear memory; clc;

dataName = 'Caltech101'

n_anchors = 400;
rand('seed',100);

dataOrigin = ['../dataset/large_scale_datasets/', dataName, '.mat'];
load(dataOrigin);

% %-------------------------cifar 10 ------------------%
% numView = length(truelabel)
% numInst = length(truelabel{1})
% %--data transform
% %--------->(numInst, fea)
% for iView = 1:numView
%     data{iView} = data{iView}';
% end
% 
% %-------------gen anchor---------------%
% Anchor = cell(numView, 1);
% for iView = 1:numView
%     Anchor{iView} = data{iView}(randperm(numInst, n_anchors),:);
% end

% %-------------------------YoutubeFace_sel_fea 10 -----------------------------%
numView = length(X)
numInst = length(Y)
%-------------gen anchor---------------%
Anchor = cell(numView, 1);
for iView = 1:numView
    Anchor{iView} = X{iView}(randperm(numInst, n_anchors),:);
end


%-------------save anchor
resultDir = 'data_anchors/'
save([resultDir, 'Anchor_', dataName, '.mat'], 'Anchor');
