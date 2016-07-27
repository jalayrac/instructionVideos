function [ f ] = compute_objective( X, z1, z2, GXTP )
% compute_objective

zzTA = 0.5 * compute_gradient(X, z1, GXTP) * z2;
f = trace(zzTA);

end