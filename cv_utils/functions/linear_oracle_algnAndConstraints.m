function [ corner ] = linear_oracle_algnAndConstraints( l, K, constrs, annot )
%OPTIMIZE_A Given the loss for all samples and all classes, and the
%annotation sequence, we find the best possible assignment

corner = cell(length(l), 1);

for i = 1:length(l)
    % adding "other" labels in between
    k = annot{i};
    T = size(l{i}, 2);    
    % building the cost matrix
    C = l{i}(k, :);
    C = filter_with_constraints(C, constrs{i});    
    [~, pathk, patht] = warp_with_jumps(C);
    corner{i} = full(sparse(patht, k(pathk), 1, T, K));
end

end