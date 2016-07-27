function [ a ] = rounding( z, clips, constrs, annot, K )
%ROUNDING Summary of this function goes here
%   Detailed explanation goes here

l = mat2cell(-2* z', K, clips);
a = linear_oracle_algnAndConstraints(l, K, constrs, annot);
a = cell2mat(a);

end

