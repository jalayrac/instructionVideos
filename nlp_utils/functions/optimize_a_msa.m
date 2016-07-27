function [ a ] = optimize_a_msa(l)
% OPTIMIZE_A_MSA: Given the loss for all samples and all classes, and the
%annotation sequence, we find the best possible assignment (this correspond
%to the linear oracle of Frank-Wolfe algorithm)

a = cell(1, length(l));
for i = 1:length(l)
    % adding "other" labels in between
    k = 1:size(l{i},2);
    T = size(l{i}, 1);
    % building the cost matrix
    C = l{i};
    [~, pathk, patht] = warp_with_jumps(C.');
    a{i} = full(sparse(patht, k(pathk), 1, T, numel(k)));
end

end
