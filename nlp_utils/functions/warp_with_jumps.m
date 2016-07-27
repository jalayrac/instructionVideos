function [y, pathk, patht] = warp_with_jumps(C)

[m, n] = size(C);

mm = min(C(:));
C = C - mm;

C_z = zeros(2*m + 1, n);
C_z(2:2:end, :) = C;

C_z = cat(2, C_z, zeros(2*m+1, 1));

[~, ~, y] = warping_jump_mex(C_z);

y(1:2:end, :) = [];
y(:, end) = [];

[pathk, patht] = find(y);

end
