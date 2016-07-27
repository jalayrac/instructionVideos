function RES_VID  = frank_wolfe_optimization_stage2( X, Z_GT, clips, ...
    constrs, annot, Z, lambda, params )

% get size of the problem with the initialization
[N, K] = size(Z);

% put the ground truth in a cell format
cell_GT   = mat2cell(Z_GT, clips, size(Z_GT,2));
% get the annotation in a matrix form of absence presence of annotation
% (used to be able to compute the precision and recall)
mat_annot = cell2mat(cellfun(@(x) sum(x)>0, cell_GT,'UniformOutput',0));
% do the same for the constraints
has_const = cell2mat(cellfun(@(x) sum(x)>0, constrs,'UniformOutput',0));  

% pre-computing heavy stuff (useful to speed up the gradient computation)
fprintf('Precomputing heavy stuff (might take a while)...\n');
GXTP = compute_GXTP(X, lambda);
fprintf('Done with precomputing...\n');

% computing the gradient
grad = compute_gradient(X, Z, GXTP);

obj  = struct('f', [], 'd', [], 't', []);

% Keeping in a big structure all the best objective for the cost classifier
% rounding

% COST CLASSIFIER ROUNDING
RES_VID.ccr.best_f_ccr = 100000; % initiate with big values
RES_VID.ccr.best_Z_ccr = [];
RES_VID.ccr.best_W_ccr = [];
RES_VID.ccr.best_b_ccr = [];
RES_VID.ccr.ccr_iter   = [];

% initial objective
i = 1;
% rebuilding the classifiers (note that differently from the paper we used
% here the formulation with explicit bias)

W = GXTP * Z;
b = ones(1, N) * (Z - X * W) / N;
f = (1/N*norm(Z-X*W-repmat(b,N,1),'fro').^2+lambda*norm(W,'fro').^2);

% ccr rounding
Z_ccr = rounding(X*W+ones(N,1)*b, clips, constrs, annot, K);

% get the best matching with the ground truth 
[jpc_ccr,jpc_ccr_all,pr2gt_ccr] = evaluate_best_matching(Z_ccr, clips, Z_GT);
 
f_ccr = compute_objective(X, Z_ccr, Z_ccr, GXTP);

if RES_VID.ccr.best_f_ccr >= f_ccr
   RES_VID.ccr.best_f_ccr = f_ccr;
   RES_VID.ccr.best_Z_ccr = Z_ccr;
   RES_VID.ccr.best_W_ccr = W;
   RES_VID.ccr.best_b_ccr = b;
   RES_VID.ccr.ccr_iter   = i;
end

% keeping track of the objective
obj(i).f        = f;
obj(i).f_ccr    = f_ccr;
obj(i).d        = 0; 

% True precision and recall
[obj(i).prec_ccr, obj(i).recall_ccr] = compute_precisionrecall(pr2gt_ccr,...
    jpc_ccr_all, mat_annot, has_const);

% additional stuff (keep results for all events and all videos !)
obj(i).perf_ccr_all  = jpc_ccr_all;
obj(i).perf_ccr      = jpc_ccr;

% keep the deduced mapping
obj(i).pr2gt_ccr = pr2gt_ccr;

tic;
for i = 2:params.niter   
    % cutting the gradient into clips
    l = mat2cell(grad, K, clips);
    
    % FW linear oracle : this gives the corner Z_fw
    Z_fwr = linear_oracle_algnAndConstraints(l, K, constrs, annot);
    Z_fwr = cell2mat(Z_fwr);

    % Linearization duality gap
    d = trace(grad*(Z-Z_fwr));
    
    % getting the optimal step size    
    gama_n = d;
    gama_d = 2 * compute_objective(X, Z_fwr-Z, Z_fwr-Z, GXTP);
    gama   = gama_n / gama_d;
    gama   = max(min(gama, 1), 0);
       
    % updating z
    Z = (1-gama) * Z + gama * Z_fwr;
    
    % rebuilding the classifiers
    W = GXTP * Z;
    b = ones(1, N) * (Z - X * W) / N;
    
    % computing objective value (speed up version because you don't need to
    % recompute W and b...
    % TODO: check that the two objetives are equal...
    f = (1/N*norm(Z-X*W-repmat(b,N,1),'fro').^2+lambda*norm(W,'fro').^2);
    
    % computing the gradient
    grad = compute_gradient(X, Z, GXTP);
       
    % ccr rounding
    Z_ccr = rounding(X*W+ones(N,1)*b, clips, constrs, annot, K);

    % evaluation of the rounded solution
    [jpc_ccr, jpc_ccr_all, pr2gt_ccr]    = evaluate_best_matching(Z_ccr, clips, Z_GT);
    [obj(i).prec_ccr, obj(i).recall_ccr] = compute_precisionrecall(pr2gt_ccr,...
        jpc_ccr_all, mat_annot, has_const);
    
    f_ccr = compute_objective(X, Z_ccr, Z_ccr, GXTP);
    
    if RES_VID.ccr.best_f_ccr >= f_ccr
       RES_VID.ccr.best_f_ccr = f_ccr;
       RES_VID.ccr.best_Z_ccr = Z_ccr;
       RES_VID.ccr.best_W_ccr = W;
       RES_VID.ccr.best_b_ccr = b;
       RES_VID.ccr.ccr_iter   = i;
    end
    
    % keeping track of the objective
    obj(i).f        = f;
    obj(i).f_ccr    = f_ccr;
    obj(i-1).d        = d;
    obj(i).t        = toc;
    obj(i).perf_ccr = jpc_ccr;
    
    
    % additional stuff (keep results for all events and all videos !)
    obj(i).perf_ccr_all  = jpc_ccr_all;
    obj(i).pr2gt_ccr = pr2gt_ccr;

    % printing the score
    fprintf('iter=%3i ',     i);
    fprintf('fobj=%-+5.3e ', f);
    fprintf('dgap=%-+5.3e ', d);
    fprintf('f1_ccr=%-+5.3f ', 2*obj(i).recall_ccr*obj(i).prec_ccr/(obj(i).recall_ccr+obj(i).prec_ccr));
    fprintf('\n');
end

% Keep the last rounding also 
RES_VID.finalr.Z_ccr    = Z_ccr;
RES_VID.finalr.ccr_perf = f_ccr;

% Keep Z, W and b at the end of the algorithm
RES_VID.relax.W_final = W;
RES_VID.relax.b_final = b;
RES_VID.relax.Z_final = Z;
RES_VID.relax.f       = f;
RES_VID.relax.dg      = d;

% Keep the parameters 
RES_VID.params  = params;

% Keep track of the objective during the whole descent
RES_VID.obj     = obj;

end


