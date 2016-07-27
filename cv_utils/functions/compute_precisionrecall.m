function [ prec, recall ] = compute_precisionrecall(pr2gt_map, predictions, annot, has_constr)
%COMPUTE_RECALL_CONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here

% remove empty predictions
has_constr = has_constr(:,pr2gt_map~=0);
pr2gt_map(pr2gt_map==0) = [];
% number of correct prediction
ncorrectpred = sum(sum(predictions(:,pr2gt_map)));
% number of things to predict
ntopredict   = sum(annot(:));
% number of predictions equal to the size of the constraints
npredictions = sum(sum(ones(size(has_constr))));

prec   = ncorrectpred./(npredictions+0.00000001);
recall = ncorrectpred./(ntopredict  +0.00000001);

end

