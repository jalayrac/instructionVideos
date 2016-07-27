function [ grad ] = compute_gradient( X, z, GXTP )
%COMPUTE_ZTA Summary of this function goes here
%   Detailed explanation goes here

[N, ~] = size(z);
zTP = bsxfun(@plus, z, -mean(z, 1))';
grad = 2 * (zTP - (zTP * X) * GXTP) / N;

end
